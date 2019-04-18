FROM ubuntu:disco
LABEL maintainer="barrie.verhagen@gmail.com"

RUN apt-get update && apt-get install --yes curl && curl -O -L https://github.com/bverhagen/exec-helper-package/releases/download/0.4.0/ubuntu-disco_exec-helper_0.4.0-1_amd64.deb && sh -c "dpkg -i *.deb || true" && apt-get --fix-broken --yes install && dpkg -i *.deb && apt-get clean && rm -rf /var/lib/apt/lists/* && rm *exec-helper*.deb
