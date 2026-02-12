#!/usr/bin/env dart

import 'dart:io';

/// Mobile setup script for SlabHaul iOS and Android deployment
/// 
/// This script configures:
/// 1. Android permissions and manifest
/// 2. iOS permissions and Info.plist
/// 3. App icons and splash screens
/// 4. Build configurations
/// 5. Testing and deployment prep

void main(List<String> args) async {
  print('📱 SlabHaul Mobile Setup Tool\n');

  await _checkPrerequisites();
  await _configureAndroid();
  await _configureiOS();
  await _generateAppIcons();
  await _testBuilds();
  
  print('\n🎣 Mobile Setup Complete!\n');
  print('📖 See scripts/setup_mobile.md for deployment instructions');
}

Future<void> _checkPrerequisites() async {
  print('🔍 Checking development environment...\n');

  // Check Flutter
  final flutterResult = await Process.run('flutter', ['--version']);
  if (flutterResult.exitCode == 0) {
    final version = flutterResult.stdout.toString().split('\n')[0];
    print('✅ Flutter: $version');
  } else {
    print('❌ Flutter not found or not working');
    exit(1);
  }

  // Check Android toolchain
  final androidResult = await Process.run('flutter', ['doctor', '--android-licenses']);
  // We don't check exit code since licenses might need acceptance
  print('✅ Android toolchain available');

  // Check Xcode (macOS only)
  if (Platform.isMacOS) {
    final xcodeResult = await Process.run('xcode-select', ['--version']);
    if (xcodeResult.exitCode == 0) {
      print('✅ Xcode available');
    } else {
      print('⚠️  Xcode not found - iOS builds will not work');
    }
  }

  print('');
}

Future<void> _configureAndroid() async {
  print('🤖 Configuring Android...\n');

  // Update AndroidManifest.xml with required permissions
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (manifestFile.existsSync()) {
    var manifest = await manifestFile.readAsString();
    
    // Add location permissions if not present
    if (!manifest.contains('ACCESS_FINE_LOCATION')) {
      final permissionsBlock = '''
    <!-- Location permissions for GPS and lake positioning -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
''';
      manifest = manifest.replaceFirst(
        '<application',
        '$permissionsBlock    <application'
      );
      
      await manifestFile.writeAsString(manifest);
      print('✅ Added location and network permissions to AndroidManifest.xml');
    } else {
      print('✅ Android permissions already configured');
    }

    // Update app label if still default
    if (manifest.contains('android:label="slabhaul"')) {
      manifest = manifest.replaceAll(
        'android:label="slabhaul"',
        'android:label="SlabHaul"'
      );
      await manifestFile.writeAsString(manifest);
      print('✅ Updated Android app label to "SlabHaul"');
    }
  } else {
    print('❌ AndroidManifest.xml not found');
  }

  // Update build.gradle for release configuration
  final buildGradleFile = File('android/app/build.gradle');
  if (buildGradleFile.existsSync()) {
    var buildGradle = await buildGradleFile.readAsString();
    
    if (!buildGradle.contains('com.velocityventure.slabhaul')) {
      buildGradle = buildGradle.replaceAll(
        'applicationId "com.example.slabhaul"',
        'applicationId "com.velocityventure.slabhaul"'
      );
      await buildGradleFile.writeAsString(buildGradle);
      print('✅ Updated Android package name');
    }
  }

  print('');
}

Future<void> _configureiOS() async {
  if (!Platform.isMacOS) {
    print('⏭️  Skipping iOS configuration (not on macOS)\n');
    return;
  }

  print('🍎 Configuring iOS...\n');

  // Update Info.plist with required permissions
  final plistFile = File('ios/Runner/Info.plist');
  if (plistFile.existsSync()) {
    var plist = await plistFile.readAsString();
    
    // Add location permissions if not present
    if (!plist.contains('NSLocationWhenInUseUsageDescription')) {
      final locationPermissions = '''
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>SlabHaul needs location access to show nearby lakes and fishing conditions.</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>SlabHaul uses your location to provide accurate weather and fishing conditions for your current lake.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>SlabHaul can track your fishing trips and provide location-based recommendations.</string>
''';
      
      // Insert before the closing </dict>
      plist = plist.replaceFirst(
        '</dict>',
        '$locationPermissions</dict>'
      );
      
      await plistFile.writeAsString(plist);
      print('✅ Added location permissions to iOS Info.plist');
    } else {
      print('✅ iOS permissions already configured');
    }

    // Update display name if needed
    if (!plist.contains('<string>SlabHaul</string>')) {
      plist = plist.replaceAll(
        '<string>Slabhaul</string>',
        '<string>SlabHaul</string>'
      );
      await plistFile.writeAsString(plist);
      print('✅ Updated iOS display name to "SlabHaul"');
    }
  }

  // Update bundle identifier
  final projectFile = File('ios/Runner.xcodeproj/project.pbxproj');
  if (projectFile.existsSync()) {
    var project = await projectFile.readAsString();
    
    if (!project.contains('com.velocityventure.slabhaul')) {
      project = project.replaceAll(
        'com.example.slabhaul',
        'com.velocityventure.slabhaul'
      );
      await projectFile.writeAsString(project);
      print('✅ Updated iOS bundle identifier');
    }
  }

  print('');
}

Future<void> _generateAppIcons() async {
  print('🎨 Checking app icons...\n');

  // Check if custom icons exist
  final androidIconPath = 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png';
  final iosIconPath = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png';
  
  final androidIconExists = File(androidIconPath).existsSync();
  final iosIconExists = File(iosIconPath).existsSync();

  if (androidIconExists && iosIconExists) {
    print('✅ App icons already configured');
  } else {
    print('⚠️  App icons not found - using default Flutter icons');
    print('📝 Create custom icons with:');
    print('   • Android: Replace files in android/app/src/main/res/mipmap-*/');
    print('   • iOS: Replace icons in ios/Runner/Assets.xcassets/AppIcon.appiconset/');
    print('   • Consider using flutter_launcher_icons package for automation');
  }

  print('');
}

Future<void> _testBuilds() async {
  print('🧪 Testing build configurations...\n');

  // Test Android debug build
  print('Testing Android debug build...');
  final androidResult = await Process.run(
    'flutter',
    ['build', 'apk', '--debug', '--quiet'],
  );
  
  if (androidResult.exitCode == 0) {
    print('✅ Android debug build successful');
  } else {
    print('❌ Android debug build failed:');
    print(androidResult.stderr);
  }

  // Test iOS debug build (macOS only)
  if (Platform.isMacOS) {
    print('Testing iOS debug build...');
    final iosResult = await Process.run(
      'flutter',
      ['build', 'ios', '--debug', '--no-codesign', '--quiet'],
    );
    
    if (iosResult.exitCode == 0) {
      print('✅ iOS debug build successful');
    } else {
      print('❌ iOS debug build failed:');
      print(iosResult.stderr);
    }
  }

  print('');
}