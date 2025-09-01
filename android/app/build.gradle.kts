plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 🔥 Required for Firebase
}

android {
    namespace = "com.example.make_your_meal"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.make_your_meal"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (manages versions automatically)
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // Firebase products you use
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}
