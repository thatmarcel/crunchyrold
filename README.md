# Crunchyrold
*Jailbreak tweak that makes older versions of the Crunchyroll app work again so you can watch on iOS 14*

By forcing app updates through disabling the API credentials of older app versions, Crunchyroll has made it impossible to watch on devices running iOS 14. This tweak allows you to use credentials of newer versions to make the app work again.

You can either obtain the required credentials (client id / username and client secret / password) yourself or let the tweak automatically download a build of the Crunchyroll Android app from APKPure and extract the credentials by itself.

The tweak has been tested with Crunchyroll 4.25.2 (the newest version that can be downloaded on iOS 14) but it might work on other versions that use the same API credentials as well.

Downloading episodes seems to be broken because the way downloads work has changed.

## Building
You need to have [Theos](https://theos.dev/docs/installation) installed.

### Rootless
To build this tweak for iOS devices on rootless jailbreaks, run the following command:
```
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
```

### Rootful
To build this tweak for iOS devices on rootful jailbreaks, run the following command:
```
make package FINALPACKAGE=1
```