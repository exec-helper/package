FROM bverhagen/awesome-aur-wrapper AS runtime
LABEL maintainer="barrie.verhagen@gmail.com"

# Install runtime dependencies
RUN sudo pacman -Sy --needed --noconfirm yaml-cpp boost-libs lua && sudo pacman -Scc --noconfirm


FROM runtime as builder

# Install build dependencies
RUN sudo pacman -Sy --needed --noconfirm base-devel meson cmake boost microsoft-gsl python-sphinx python-sphinx_rtd_theme git pkg-config lsb-release python libffi && sudo pacman -Scc --noconfirm

## Install gitchangelog using the standalone installer
RUN sudo sh -c 'curl -sSL https://raw.githubusercontent.com/vaab/gitchangelog/master/src/gitchangelog/gitchangelog.py > /usr/local/bin/gitchangelog' && sudo sh -c 'chmod +x /usr/local/bin/gitchangelog'

COPY . /exec-helper
RUN sudo chown -R awesome:awesome /exec-helper
WORKDIR /exec-helper
RUN make TARGET=binary arch


FROM runtime

# Copy and install binary package
COPY --from=builder /exec-helper/pkgbuild/build_package/exec-helper*.tar.xz /tmp/
RUN sudo pacman -U --noconfirm /tmp/exec-helper*.tar.xz
RUN rm -rf /tmp/exec-helper*.tar.xz
