import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from android/key.properties (rootProject is android/)
val keystorePropertiesFile = if (rootProject.file("key.properties").exists()) {
    rootProject.file("key.properties")
} else {
    // backward compatibility for incorrect old path
    rootProject.file("android/key.properties")
}
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

fun readKeystoreProp(name: String): String? {
    val direct = keystoreProperties.getProperty(name)
    if (!direct.isNullOrBlank()) return direct.trim()
    // Handle UTF-8 BOM on first key (e.g. "\uFEFFstorePassword")
    val fromEntries = keystoreProperties.entries.firstOrNull { (k, _) ->
        k.toString().trimStart('\uFEFF').trim() == name
    }?.value?.toString()
    return fromEntries?.trim()?.takeIf { it.isNotEmpty() }
}

android {
    namespace = "com.likelife.musiclike"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID used on the Play Store
        applicationId = "com.likelife.musiclike"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // Set to 24 to support modern Android APIs and avoid ClassNotFoundException
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = readKeystoreProp("keyAlias")
            keyPassword = readKeystoreProp("keyPassword")
            val storePath = readKeystoreProp("storeFile")
            if (!storePath.isNullOrBlank()) {
                // key.properties is in android/, so relative paths should resolve from rootProject (android/)
                val f = File(storePath)
                storeFile = if (f.isAbsolute) f else rootProject.file(storePath)
            }
            storePassword = readKeystoreProp("storePassword")
            storeType = readKeystoreProp("storeType") ?: "pkcs12"
        }
    }

    buildTypes {
        release {
            // Use release signing config when available; fallback to debug if not.
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            // Enable code shrinking when removing unused resources
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
