#!/bin/bash
sudo dnf -y install meson
sudo dnf -y install vala
sudo dnf -y install libappstream-glib
sudo dnf -y install gtk3-devel
sudo dnf -y install libhandy1
sudo dnf -y install libhandy
sudo dnf -y install libhandy-devel
meson build --prefix=/usr
cd build
ninja
sudo ninja install
