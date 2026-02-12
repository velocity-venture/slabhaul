# SlabHaul Mobile Setup Guide

## Overview
Setting up SlabHaul for iOS and Android deployment with proper app icons, permissions, and production configuration.

## Prerequisites ✅
- Flutter 3.38.9+ installed
- Android Studio with SDK
- Xcode 26.1+ (for iOS)
- macOS for iOS development

## Current Status
- ✅ Flutter project structure ready
- ✅ Android toolchain configured
- ✅ Xcode development environment
- ✅ Development certificates available

## 1. Android Configuration

### App Identity
- **Package Name:** `com.velocityventure.slabhaul`
- **App Name:** SlabHaul
- **Version:** 0.1.0+1

### Required Permissions
- `INTERNET` - Weather data and Supabase
- `ACCESS_COARSE_LOCATION` - Lake location services
- `ACCESS_FINE_LOCATION` - GPS positioning
- `WAKE_LOCK` - Keep screen on during active fishing

### Build Configuration
```bash
# Debug build
flutter build apk --debug

# Release build  
flutter build appbundle --release

# Install on connected device
flutter install
```

## 2. iOS Configuration

### App Identity
- **Bundle ID:** `com.velocityventure.slabhaul`
- **Display Name:** SlabHaul
- **Version:** 0.1.0 (1)

### Required Permissions
- Location Services - Lake and weather positioning
- Network Access - API calls and data sync

### Build Configuration
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Archive for App Store
flutter build ios --release --no-codesign
```

## 3. App Icons & Assets

### Icon Requirements
- **Android:** Multiple sizes (48dp to 512dp)
- **iOS:** Multiple sizes (20pt to 1024pt)
- **Design:** Fishing/crappie themed with SlabHaul branding

### Splash Screens
- **Android:** Launch screen with app logo
- **iOS:** LaunchScreen.storyboard with branding

## 4. Production Configuration

### Environment Variables
```env
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
```

### Release Signing
- **Android:** Generate release keystore
- **iOS:** Distribution certificates and provisioning profiles

## 5. Testing Strategy

### Device Testing
- Test on physical Android devices (various screen sizes)
- Test on physical iOS devices (iPhone + iPad)
- Verify GPS and network functionality

### Performance Testing
- Weather data loading performance
- Map rendering with attractors
- Trip planner responsiveness
- Database sync reliability

## 6. Deployment Preparation

### Android Play Store
1. Create Google Play Console account
2. Upload signed AAB (App Bundle)
3. Configure store listing with screenshots
4. Set up release management

### iOS App Store  
1. Apple Developer Account required
2. Archive and upload via Xcode or Application Loader
3. Configure App Store Connect listing
4. Submit for review

## Next Steps

Run the automated setup script:
```bash
dart scripts/setup_mobile.dart
```

This will:
- Configure permissions and manifests
- Generate app icons
- Set up build configurations
- Test build processes
- Prepare deployment assets

## Demo-Ready Features

For County Commission presentation:
- **Smart Trip Planner** with radar chart
- **Real-time weather integration**
- **Interactive attractor maps**
- **Professional mobile UI**
- **Offline-capable architecture**

The mobile apps showcase modern AI-powered fishing intelligence with production-ready deployment capability.