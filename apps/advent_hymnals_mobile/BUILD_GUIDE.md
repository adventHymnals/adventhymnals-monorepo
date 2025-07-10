# Build Guide - Advent Hymnals Mobile

This guide will help you compile the Advent Hymnals Mobile app for Android (APK) and Windows platforms.

## Prerequisites

### General Requirements
- Flutter SDK (3.13.0 or higher)
- Dart SDK (included with Flutter)
- Git

### For Android APK Building
- Android Studio or Android SDK Command Line Tools
- Java Development Kit (JDK) 11 or higher
- Android SDK with API level 33 or higher

### For Windows App Building
- Visual Studio 2022 or Visual Studio Build Tools 2022
- Windows 10 SDK (10.0.17763.0 or higher)
- CMake (usually included with Visual Studio)

## Setup Instructions

### 1. Verify Flutter Installation
```bash
flutter doctor
```
Ensure all checkmarks are green for your target platforms.

### 2. Enable Required Platforms
```bash
flutter config --enable-android --enable-windows-desktop
```

### 3. Get Dependencies
```bash
cd /path/to/advent-hymnals-mono-repo/apps/advent_hymnals_mobile
flutter pub get
```

## Building Android APK

### Debug APK (for testing)
```bash
# Build debug APK
flutter build apk --debug

# Output location: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for distribution)
```bash
# Build release APK
flutter build apk --release

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs by Architecture (recommended for smaller file sizes)
```bash
# Build separate APKs for different architectures
flutter build apk --split-per-abi --release

# Outputs:
# - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (for 64-bit ARM devices)
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (for 32-bit ARM devices)
# - build/app/outputs/flutter-apk/app-x86_64-release.apk (for 64-bit Intel devices)
```

### Fat APK (single APK for all architectures)
```bash
# Build universal APK (larger file size)
flutter build apk --release --no-split-per-abi

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

## Building Windows Application

### Debug Build (for testing)
```bash
# Build debug Windows app
flutter build windows --debug

# Output location: build/windows/x64/runner/Debug/
```

### Release Build (for distribution)
```bash
# Build release Windows app
flutter build windows --release

# Output location: build/windows/x64/runner/Release/
```

## App Signing (For Production Release)

### Android APK Signing

1. **Create a keystore** (one-time setup):
```bash
keytool -genkey -v -keystore ~/advent-hymnals-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias advent-hymnals
```

2. **Create key.properties file** in `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=advent-hymnals
storeFile=/path/to/advent-hymnals-key.jks
```

3. **Update android/app/build.gradle** to use signing:
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Build signed APK**:
```bash
flutter build apk --release
```

## Build Commands Summary

### Quick Build Commands

```bash
# Android Debug APK
flutter build apk --debug

# Android Release APK
flutter build apk --release

# Android Release APK (split by architecture)
flutter build apk --split-per-abi --release

# Windows Debug
flutter build windows --debug

# Windows Release
flutter build windows --release
```

## Distribution

### Android APK Distribution
- **Debug APK**: Share directly via file transfer
- **Release APK**: 
  - Upload to Google Play Store (recommended)
  - Distribute via direct download (enable "Unknown Sources" required)
  - Use APK hosting services

### Windows App Distribution
- **Installer Creation**: Use tools like Inno Setup or NSIS to create an installer
- **Direct Distribution**: Zip the contents of `build/windows/x64/runner/Release/` folder
- **Microsoft Store**: Package as MSIX for Microsoft Store distribution

## File Locations After Build

### Android APK Files
```
build/app/outputs/flutter-apk/
├── app-debug.apk                    (Debug APK)
├── app-release.apk                  (Release APK - universal)
├── app-arm64-v8a-release.apk       (64-bit ARM)
├── app-armeabi-v7a-release.apk     (32-bit ARM)
└── app-x86_64-release.apk          (64-bit Intel)
```

### Windows App Files
```
build/windows/x64/runner/
├── Debug/                          (Debug build)
│   ├── advent_hymnals_mobile.exe
│   ├── flutter_windows.dll
│   └── data/
└── Release/                        (Release build)
    ├── advent_hymnals_mobile.exe
    ├── flutter_windows.dll
    └── data/
```

## Troubleshooting

### Common Android Issues
1. **Gradle build errors**: Update Android SDK and Gradle versions
2. **Signing errors**: Verify keystore path and passwords
3. **Memory issues**: Add `org.gradle.jvmargs=-Xmx4g` to `gradle.properties`

### Common Windows Issues
1. **Visual Studio not found**: Install Visual Studio 2022 with C++ tools
2. **CMake errors**: Ensure CMake is in PATH
3. **Windows SDK missing**: Install Windows 10 SDK

### Dependencies Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release  # or flutter build windows --release
```

## Testing Built Apps

### Testing Android APK
1. Install on Android device: `adb install app-release.apk`
2. Or transfer APK file and install directly on device

### Testing Windows App
1. Navigate to `build/windows/x64/runner/Release/`
2. Double-click `advent_hymnals_mobile.exe`
3. Ensure all DLL files are in the same directory

## Build Optimization

### Reducing APK Size
```bash
# Enable R8 obfuscation and minification
flutter build apk --release --obfuscate --split-debug-info=debug-info/

# Split by ABI
flutter build apk --release --split-per-abi
```

### Windows App Optimization
```bash
# Release build automatically optimizes
flutter build windows --release

# For smaller executable, use:
flutter build windows --release --tree-shake-icons
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build Apps

on: [push, pull_request]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '11'
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build windows --release
```

---

For more detailed information, refer to the [Flutter documentation](https://docs.flutter.dev/deployment).