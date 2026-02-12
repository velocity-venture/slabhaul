#!/usr/bin/env dart

import 'dart:io';

/// Setup script for SlabHaul production Supabase configuration
/// 
/// This script helps configure the production environment by:
/// 1. Checking current configuration
/// 2. Validating environment variables
/// 3. Testing database connectivity
/// 4. Providing setup guidance

void main(List<String> args) async {
  print('🎣 SlabHaul Production Setup Tool\n');

  // Check if .env exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    print('📋 Creating .env from template...\n');
    
    final exampleFile = File('.env.example');
    if (exampleFile.existsSync()) {
      await envFile.writeAsString(await exampleFile.readAsString());
      print('✅ Created .env file from template');
      print('📝 Please edit .env with your production Supabase credentials\n');
    } else {
      print('❌ .env.example not found. Creating basic template...');
      await envFile.writeAsString('''
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
MAPBOX_ACCESS_TOKEN=optional-for-future-use
''');
    }
  }

  // Read and validate .env
  final envContent = await envFile.readAsString();
  final lines = envContent.split('\n');
  final envVars = <String, String>{};
  
  for (final line in lines) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        envVars[parts[0]] = parts.sublist(1).join('=');
      }
    }
  }

  print('🔍 Checking environment configuration...\n');

  // Validate Supabase URL
  final supabaseUrl = envVars['SUPABASE_URL'] ?? '';
  if (supabaseUrl.isEmpty || supabaseUrl.contains('your-project')) {
    print('❌ SUPABASE_URL not configured');
    print('   Please set your production Supabase URL');
  } else if (!supabaseUrl.startsWith('https://') || !supabaseUrl.contains('.supabase.co')) {
    print('⚠️  SUPABASE_URL format may be incorrect: $supabaseUrl');
    print('   Expected format: https://your-project-id.supabase.co');
  } else {
    print('✅ SUPABASE_URL configured: ${supabaseUrl.replaceAll(RegExp(r'https://(.+?)\.supabase\.co'), 'https://*****.supabase.co')}');
  }

  // Validate Supabase anon key  
  final anonKey = envVars['SUPABASE_ANON_KEY'] ?? '';
  if (anonKey.isEmpty || anonKey.contains('your-anon-key')) {
    print('❌ SUPABASE_ANON_KEY not configured');
    print('   Please set your production Supabase anon key');
  } else if (!anonKey.startsWith('eyJ')) {
    print('⚠️  SUPABASE_ANON_KEY format may be incorrect');
    print('   Expected to start with "eyJ"');
  } else {
    print('✅ SUPABASE_ANON_KEY configured: ${anonKey.substring(0, 20)}...');
  }

  print('\n🗄️  Checking database migrations...\n');

  // Check migrations directory
  final migrationsDir = Directory('supabase/migrations');
  if (!migrationsDir.existsSync()) {
    print('❌ Migrations directory not found');
    print('   Run: supabase init (if not already done)');
  } else {
    final migrations = migrationsDir.listSync()
        .where((f) => f.path.endsWith('.sql'))
        .map((f) => f.path.split('/').last)
        .toList();
    
    if (migrations.isEmpty) {
      print('⚠️  No migration files found');
    } else {
      print('✅ Found ${migrations.length} migration files:');
      for (final migration in migrations) {
        print('   • $migration');
      }
    }
  }

  print('\n🚀 Next Steps for Production Deployment:\n');

  if (supabaseUrl.contains('your-project') || anonKey.contains('your-anon-key')) {
    print('1. 📝 Update .env with your production Supabase credentials');
    print('   • Get URL and anon key from https://supabase.com/dashboard');
    print('   • Go to Settings → API in your project dashboard\n');
  }

  print('2. 🗄️  Deploy database schema to production:');
  print('   supabase link --project-ref your-project-id');
  print('   supabase db push\n');

  print('3. 🧪 Test the connection:');
  print('   flutter run');
  print('   Check logs for "SupabaseService initialized successfully"\n');

  print('4. 📱 Build for production:');
  print('   flutter build ios --release');
  print('   flutter build appbundle --release\n');

  print('📖 See scripts/setup_production_supabase.md for detailed instructions');
}