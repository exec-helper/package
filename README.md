# exec-helper-package
Packaging repository builder for the [exec-helper](https://github.com/bverhagen/exec-helper) project.

## Supported systems
### Package systems
The following packaging systems are currently supported:
- PKGBUILD
- dpkg

### Supported operating systems
The following operating systems are currently automatically detected when building:
- Arch linux
- Debian
- Ubuntu

## Building a package
Building a package can be done using:
    make
or
    make build

Build dependencies can be found in the expected files of your package manager.

## Dev repository
The development repository can be found at [https://gitlab.com/bverhagen/exec-helper-package].
