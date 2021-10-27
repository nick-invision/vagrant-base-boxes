#! /bin/bash

short_name="${short_name:-"monterey"}"
full_name="${full_name:-"Monterey"}"

hdiutil create -o "/tmp/${short_name}" -size 14250m -volname "${short_name}" -layout SPUD -fs HFS+J
hdiutil attach "/tmp/${short_name}.dmg" -noverify -mountpoint "/Volumes/${short_name}"
sudo "/Applications/Install macOS ${full_name}.app/Contents/Resources/createinstallmedia" --volume "/Volumes/${short_name}" --nointeraction
hdiutil eject -force "/Volumes/Install macOS ${full_name}"
hdiutil convert "/tmp/${short_name}.dmg" -format UDTO -o "$HOME/Desktop/${short_name}.cdr"
mv "$HOME/Desktop/${short_name}.cdr" "$HOME/Desktop/${short_name}.iso"