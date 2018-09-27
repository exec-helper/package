# exec-helper-package
[![pipeline status](https://gitlab.com/bverhagen/exec-helper-package/badges/master/pipeline.svg)](https://gitlab.com/bverhagen/exec-helper-package/commits/master)

Packaging repository builder for the [exec-helper](https://github.com/bverhagen/exec-helper) project.

## Supported systems
### Package systems
The following packaging systems are currently supported:
- PKGBUILD
- dpkg

### Supported operating systems
The following operating systems are currently automatically detected when building:
- Arch linux
- Debian (testing)
- Ubuntu (Bionic and roling)

### Containers
Containers with exec-helper pre-installed can be found for the following container technologies:
- Docker: On [Docker Hub](https://hub.docker.com/r/bverhagen/exec-helper-package/). _note:_ Different operating systems use different tags, so make sure to check these out in order to verify whether your system is currently supported.

## Building a source package
Use:
    make
or
    make prepare

## Building a binary, installable package
Use:
    make build
    make install PREFIX=<installation prefix>

where the installation prefix is the root of the path where you want to install the binary package. By default this is in a _package_ subdirectory in the root of this repository.

Build dependencies can be found in the expected files of your package manager or resolved by your package manager.

## Dev repository
The development repository can be found at [https://gitlab.com/bverhagen/exec-helper-package].
