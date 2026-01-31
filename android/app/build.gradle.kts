plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Obligatorio para Flutter moderno:
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fabricsapp"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.fabricsapp"
        minSdk = 21
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}
