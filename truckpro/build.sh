if [ "$1" == "android" ]; then
    sed -i '' '/pspdfkit_flutter/d' pubspec.yaml
    flutter clean
    flutter pub get
    flutter build apk
elif [ "$1" == "ios" ]; then
    echo "Adding pspdfkit_flutter for iOS build"
    flutter pub get
    flutter build ios
fi
