import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lms.lms_mobile"

    // Matches the Android SDK / Build Tools you already have installed
    // (Android SDK Platform 37 / Build Tools 36). compileSdk 36 is the
    // highest "stable" target broadly supported by current plugins; bump to
    // 37 later if a plugin specifically requires it.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Target JDK 17 bytecode regardless of which JDK actually runs Gradle -
        // this is what keeps the build working whether Gradle ends up running
        // on JDK 17, 21, or (once AGP catches up) 25.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.lms.lms_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signed with the debug key for now so `flutter run --release` and
            // `flutter build apk` work out of the box. Swap in a real
            // signingConfig before shipping to the Play Store.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
