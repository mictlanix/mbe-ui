import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Per-brand identity (spec 045). tool/release.sh writes android/brand.properties
// (gitignored) for a non-default brand; absent => white-label defaults.
val brand = Properties().apply {
    val f = rootProject.file("brand.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.mictlanix.mbe_ui"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = brand.getProperty("APPLICATION_ID", "com.mictlanix.mbe")
        resValue("string", "app_name", brand.getProperty("DISPLAY_NAME", "Mictlanix Business Essentials"))
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing comes from the environment (spec 045 FR-023): the upload
    // keystore lives outside the repository. Debug builds never need it.
    signingConfigs {
        create("release") {
            System.getenv("MBE_ANDROID_KEYSTORE_PATH")?.let { storeFile = file(it) }
            storePassword = System.getenv("MBE_ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("MBE_ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("MBE_ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseTask = Regex("^:app:(assemble|bundle|package).*Release$")
    if (allTasks.any { releaseTask.matches(it.path) }) {
        val missing = listOf(
            "MBE_ANDROID_KEYSTORE_PATH",
            "MBE_ANDROID_KEYSTORE_PASSWORD",
            "MBE_ANDROID_KEY_ALIAS",
            "MBE_ANDROID_KEY_PASSWORD",
        ).filter { System.getenv(it).isNullOrEmpty() }
        if (missing.isNotEmpty()) {
            throw GradleException(
                "Release builds are signed with the upload key; set: ${missing.joinToString(", ")}",
            )
        }
    }
}

flutter {
    source = "../.."
}
