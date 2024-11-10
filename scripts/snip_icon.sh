#!/bin/bash

if [ -z "$1" ]; then
  SOURCE="assets/icon/icon-1024.png"
else
  SOURCE="$1"
fi

# assets
DIST_DIR="assets/icon"
sips -z 1000 1000 $SOURCE -o $DIST_DIR/icon-1000.png
sips -z 512 512 $SOURCE -o $DIST_DIR/icon-512.png
sips -z 192 192 $SOURCE -o $DIST_DIR/icon-192.png
sips -z 120 120 $SOURCE -o $DIST_DIR/icon-120.png
sips -z 120 120 $SOURCE -o $DIST_DIR/../tutorial/assets/images/icon-120.png

# android
DIST_DIR="android/app/src/main/res"
sips -z 192 192 $SOURCE -o $DIST_DIR/mipmap-xxxhdpi/ic_launcher.png
sips -z 144 144 $SOURCE -o $DIST_DIR/mipmap-xxhdpi/ic_launcher.png
sips -z 96 96 $SOURCE -o $DIST_DIR/mipmap-xhdpi/ic_launcher.png
sips -z 72 72 $SOURCE -o $DIST_DIR/mipmap-hdpi/ic_launcher.png
sips -z 48 48 $SOURCE -o $DIST_DIR/mipmap-mdpi/ic_launcher.png

# ios
DIST_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
sips -z 1024 1024 $SOURCE -o $DIST_DIR/Icon-App-1024x1024@1x.png
sips -z 167 167 $SOURCE -o $DIST_DIR/Icon-App-83.5x83.5@2x.png
sips -z 152 152 $SOURCE -o $DIST_DIR/Icon-App-76x76@2x.png
sips -z 76 76 $SOURCE -o $DIST_DIR/Icon-App-76x76@1x.png
sips -z 180 180 $SOURCE -o $DIST_DIR/Icon-App-60x60@3x.png
sips -z 120 120 $SOURCE -o $DIST_DIR/Icon-App-60x60@2x.png
sips -z 120 120 $SOURCE -o $DIST_DIR/Icon-App-40x40@3x.png
sips -z 80 80 $SOURCE -o $DIST_DIR/Icon-App-40x40@2x.png
sips -z 40 40 $SOURCE -o $DIST_DIR/Icon-App-40x40@1x.png
sips -z 87 87 $SOURCE -o $DIST_DIR/Icon-App-29x29@3x.png
sips -z 58 58 $SOURCE -o $DIST_DIR/Icon-App-29x29@2x.png
sips -z 29 29 $SOURCE -o $DIST_DIR/Icon-App-29x29@1x.png
sips -z 60 60 $SOURCE -o $DIST_DIR/Icon-App-20x20@3x.png
sips -z 40 40 $SOURCE -o $DIST_DIR/Icon-App-20x20@2x.png
sips -z 20 20 $SOURCE -o $DIST_DIR/Icon-App-20x20@1x.png

# macos
DIST_DIR="macos/Runner/Assets.xcassets/AppIcon.appiconset"
sips -z 1024 1024 $SOURCE -o $DIST_DIR/app_icon_1024.png
sips -z 512 512 $SOURCE -o $DIST_DIR/app_icon_512.png
sips -z 256 256 $SOURCE -o $DIST_DIR/app_icon_256.png
sips -z 128 128 $SOURCE -o $DIST_DIR/app_icon_128.png
sips -z 64 64 $SOURCE -o $DIST_DIR/app_icon_64.png
sips -z 32 32 $SOURCE -o $DIST_DIR/app_icon_32.png
sips -z 16 16 $SOURCE -o $DIST_DIR/app_icon_16.png

# # windows
# # https://www.aconvert.com/cn/icon/png-to-ico/ 16,24,32,48,256
# DIST_DIR="windows/runner/resources"

echo "Icon generation complete.😘"
