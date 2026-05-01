#!/bin/sh

read -p "Continue? This will back up your existing config for Rofi, Awesome, and Kitty. (y/n) " yn

case $yn in
    [Yy]* ) echo " ";;
    [Nn]* ) echo "Received N. Abort."; exit;;
    * ) echo "Please answer yes or no.";;
esac


mkdir ~/awesome-backup

sudo pacman -S awesome rofi kitty feh
feh --bg-fill ./wallpaper.png
cp -r ~/.config/awesome ~/awesome-backup/
cp -r ~/.config/rofi ~/awesome-backup/
cp -r ~/.config/kitty ~/awesome-backup/

cp -r ./awesome ~/.config/awesome
cp -r ./rofi ~/.config/rofi
cp -r ./kitty ~/.config/kitty

echo "Installer finished. If you are currently in awesome, refresh the desktop."
