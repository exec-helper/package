FROM ubuntu:bionic
LABEL maintainer="barrie.verhagen@gmail.com"

RUN apt-get update
RUN apt-get install --yes curl
RUN curl -O -L https://github.com/bverhagen/exec-helper-package/releases/download/0.3.0/ubuntu-bionic_exec-helper_0.3.0-1_amd64.deb
RUN dpkg -i *.deb || true
RUN apt-get --fix-broken --yes install && dpkg -i *.deb && apt-get clean