FROM bverhagen/pacman-aur-wrapper

RUN yay -Sy --needed --noconfirm exec-helper-git && sudo pacman -Scc --noconfirm && rm -rf /tmp/makepkg
