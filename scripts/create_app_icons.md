# SlabHaul App Icon Guide

## Current Status
✅ Default Flutter icons are configured
⏳ Custom SlabHaul branding icons needed

## Icon Requirements

### Android Icons
Required sizes in `android/app/src/main/res/`:
- `mipmap-mdpi/ic_launcher.png` (48x48dp)
- `mipmap-hdpi/ic_launcher.png` (72x72dp)
- `mipmap-xhdpi/ic_launcher.png` (96x96dp)
- `mipmap-xxhdpi/ic_launcher.png` (144x144dp)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192dp)

### iOS Icons  
Required in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- Multiple sizes from 20pt to 1024pt
- Both @2x and @3x variants for retina displays

## Design Recommendations

### Theme: Crappie Fishing Intelligence
- **Primary:** Stylized crappie fish silhouette
- **Secondary:** Tech/AI element (circuit pattern, radar waves)
- **Colors:** Teal primary (#0D9488), dark background
- **Style:** Modern, professional, recognizable at small sizes

### Automated Generation
Use the `flutter_launcher_icons` package:

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#0F172A"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

2. Generate:
```bash
dart run flutter_launcher_icons:main
```

## Design Assets Needed

### Master Icon (1024x1024px)
- High-resolution source for all sizes
- PNG with transparent background
- Crappie + tech fusion design

### Adaptive Icon (Android)
- Foreground: 432x432px (icon shape)
- Background: 432x432px (solid color or pattern)
- Safe area: 264x264px center (account for masking)

## Branding Elements
- **App Name:** SlabHaul
- **Tagline:** "Smart Crappie Fishing"
- **Visual Identity:** Professional fishing tech
- **Target Users:** Serious anglers who embrace technology

## Implementation Steps
1. Design master 1024x1024 app icon
2. Create adaptive foreground/background
3. Run `flutter_launcher_icons` generator
4. Test on multiple devices and OS versions
5. Verify App Store and Play Store compliance

## County Commission Demo
Professional app icons demonstrate:
- ✅ Production-ready mobile applications
- ✅ Professional brand identity
- ✅ Market-ready deployment capability
- ✅ Modern tech stack implementation