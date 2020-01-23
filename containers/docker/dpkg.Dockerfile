ARG BASE_IMAGE
FROM ${BASE_IMAGE} as builder
LABEL maintainer="barrie.verhagen@gmail.com"

# It is required to keep this in order for lsb_release to work
RUN apt-get update

# Install build dependencies
RUN apt-get install --assume-yes git build-essential make cmake bison flex python3 python3-mako debhelper equivs devscripts sudo lsb-release sed libboost-program-options-dev libboost-filesystem-dev libboost-log-dev libyaml-cpp-dev libmsgsl-dev graphviz pkg-config curl

## Install gitchangelog using the standalone installer
RUN sudo sh -c 'curl -sSL https://raw.githubusercontent.com/vaab/gitchangelog/master/src/gitchangelog/gitchangelog.py > /usr/local/bin/gitchangelog' && sudo sh -c 'chmod +x /usr/local/bin/gitchangelog' && [ -f /usr/bin/python ] || ln -s python3 /usr/bin/python

## Install Doxygen
RUN git clone https://github.com/doxygen/doxygen.git && cd doxygen && git checkout Release_1_8_17 && cmake -H. -Bbuild && make -C build && make -C build install && cd ..

# Build the package
COPY . /exec-helper
WORKDIR /exec-helper 
RUN chmod a+w dpkg
RUN sudo -u nobody make -C dpkg build


# Install the package in a 'clean' environment
FROM ${BASE_IMAGE}
LABEL maintainer="barrie.verhagen@gmail.com"

# Copy and install pre-build package
COPY --from=builder /exec-helper/dpkg/package/binary/exec-helper_*.deb /exec-helper/dpkg/package/binary/exec-helper-docs*.deb /tmp/
RUN apt-get update && sh -c "dpkg -i /tmp/exec-helper*.deb || true" && apt-get --fix-broken --yes install && dpkg -i /tmp/exec-helper*.deb && apt-get clean && rm -rf /var/lib/apt/lists/* && rm /tmp/exec-helper*.deb
