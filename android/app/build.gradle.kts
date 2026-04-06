import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.coupony"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.coupony"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ── Google Maps API Key injection ──────────────────────────────────
        // Priority: CI env var → android/local.properties → empty string.
        // The key is referenced in AndroidManifest.xml as ${mapsApiKey}.
        //
        // For local development, the key is stored in android/local.properties
        // (gitignored). For CI/CD, set MAPS_API_KEY_ANDROID as a secret env var.
        val localProps = Properties()
        rootProject.file("local.properties")
            .takeIf { it.exists() }
            ?.inputStream()
            ?.use { localProps.load(it) }

        manifestPlaceholders["mapsApiKey"] =
            System.getenv("MAPS_API_KEY_ANDROID")
                ?: localProps.getProperty("MAPS_API_KEY_ANDROID", "")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
