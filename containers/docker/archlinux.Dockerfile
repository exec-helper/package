FROM bverhagen/pacman-aur-wrapper
LABEL maintainer="barrie.verhagen@gmail.com"

RUN yay -Sy --needed --noconfirm exec-helper-git && sudo pacman -Scc --noconfirm && rm -rf /tmp/makepkg
