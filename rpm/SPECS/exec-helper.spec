#
# spec file for package exec-helper
#
# Copyright (c) 2022 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           exec-helper
Version:        @SHORT_VERSION@
Release:        @RELEASE@
Summary:        How To Get Coffee In Peace: a shell meta-wrapper

License:        BSD-3-Clause
URL:            https://github.com/exec-helper/source
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  gcc-c++ meson cmake libboost_program_options-devel libboost_filesystem-devel libboost_log-devel yaml-cpp-devel lua53-devel python3-Sphinx python3-sphinx_rtd_theme pkg-config


%description
This package provides the exec-helper binaries and the man-page documentation.


%prep
%setup -q

%build
%meson --unity on -D "usage-documentation=true" -D "api-documentation=false" -D "plugins-prefix=/usr/share/exec-helper/plugins" -D "test=false" -D "version=@VERSION@" -D "copyright=Copyright (c) $(date +'%Y') Bart Verhagen" -D "use-system-yaml-cpp=enabled" -D "use-system-lua=enabled"
%meson_build

%install
%meson_install

%files
%{_bindir}/exec-helper
%{_bindir}/eh
%{_datadir}/exec-helper
%{_datadir}/bash-completion/eh
%{_datadir}/bash-completion/exec-helper
%{_datadir}/zsh/functions
#%{_datadir}/zsh/functions/Completion/Unix/_eh
#%{_datadir}/zsh/functions/Completion/Unix/_exec-helper
%{_mandir}/man1/*.1*
%{_mandir}/man5/*.5*

%license LICENSE

%changelog
