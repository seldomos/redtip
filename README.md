# Redtip

Redtip is a systemd Service Manager(fork Ketip).

![screenshot](https://i.imgur.com/FHe9A38.png)

## Building and Installation(auto for RedOS) - recommend
At first run `sudo chmod a+x install-script.sh` ;

After run `sudo ./install-script.sh` to auto-install all packages and building programm

## Building and Installation(manually)

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install

To uninstall, use `ninja uninstall`

    sudo ninja uninstall

## Acknowledgements

Thanks to author [hahnavi](https://github.com/hahnavi/), and thanks to [JetBrains](https://www.jetbrains.com) for supporting the [free Open Source License](https://www.jetbrains.com/buy/opensource)
