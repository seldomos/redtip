# Redtip

Redtip is a systemd Service Manager(fork Ketip).

![screenshot](data/screenshot.png?raw=true)

## Building and Installation(auto for RedOS)

Run `sudo ./install-script.sh` to auto-install all packages and building programm

## Building and Installation(manually)

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install

To uninstall, use `ninja uninstall`

    sudo ninja uninstall