pluginManagement {
    val props = java.util.Properties()
    file("local.properties").inputStream().use { props.load(it) }
    val flutterSdk = requireNotNull(props.getProperty("flutter.sdk")) { "flutter.sdk not set in local.properties" }

    includeBuild("$flutterSdk/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.10.1" apply false
    id("com.android.library")     version "8.10.1" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}

include(":app")
