ARG BASE_IMAGE
FROM ${BASE_IMAGE} as builder
LABEL maintainer="barrie.verhagen@gmail.com"

## Tzdata fix
ENV DEBIAN_FRONTEND noninteractive    
COPY containers/docker/debconf /tmp/    
RUN debconf-set-selections /tmp/debconf && rm /tmp/debconf

# It is required to keep this in order for lsb_release to work
RUN apt-get update

# Install build dependencies
RUN apt-get install --assume-yes git build-essential meson cmake bison flex python3 python3-mako python3-sphinx python3-sphinx-rtd-theme debhelper equivs devscripts sudo lsb-release sed libboost-program-options-dev libboost-filesystem-dev libboost-log-dev libyaml-cpp-dev libmsgsl-dev liblua5.3-dev pkg-config curl

## Install gitchangelog using the standalone installer
RUN sudo sh -c 'curl -sSL https://raw.githubusercontent.com/vaab/gitchangelog/master/src/gitchangelog/gitchangelog.py > /usr/local/bin/gitchangelog' && sudo sh -c 'chmod +x /usr/local/bin/gitchangelog' && [ -f /usr/bin/python ] || ln -s python3 /usr/bin/python

# Build the package
COPY . /exec-helper
WORKDIR /exec-helper
RUN chmod a+w dpkg
RUN make -C dpkg binary


# Install the package in a 'clean' environment
FROM ${BASE_IMAGE}
LABEL maintainer="barrie.verhagen@gmail.com"

# Copy and install binary package
COPY --from=builder /exec-helper/dpkg/package/binary/exec-helper_*.deb /exec-helper/dpkg/package/binary/exec-helper-docs*.deb /tmp/
RUN apt-get update && sh -c "dpkg -i /tmp/exec-helper*.deb || true" && apt-get --fix-broken --yes install && dpkg -i /tmp/exec-helper*.deb && apt-get clean && rm -rf /var/lib/apt/lists/* && rm /tmp/exec-helper*.deb
