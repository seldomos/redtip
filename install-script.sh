#!/bin/bash
#Colors for text output
#Цвета для вывода текста
GREEN='\033[0;32m'
NC='\033[0m'

#Installing packages to run the program
#Установка пакетов для запуска программы
sudo dnf -y install meson
sudo dnf -y install vala
sudo dnf -y install libappstream-glib
sudo dnf -y install gtk3-devel
sudo dnf -y install libhandy-devel

#Run "meson" to configure the build environment
#Запуск программы "meson" для настройки среды сборки
meson build --prefix=/usr

#Run "ninja" to build program
#Запуск программы "ninja" для сборки программы
cd build
ninja

#Install program
#Установка программы
sudo ninja install

echo -e "${GREEN}Отлично! Запустите Redtip из списка меню программ${NC}"
echo -e "${GREEN}Great! Start Redtip from the program menu list${NC}"