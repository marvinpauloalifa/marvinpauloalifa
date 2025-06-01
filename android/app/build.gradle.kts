plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.farmacia2pdm"
    compileSdk = 35// substitua por flutter.compileSdkVersion se estiver definido no build.gradle raiz
    ndkVersion = "27.0.12077973"
    // ou use flutter.ndkVersion se estiver definido

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.farmacia2pdm"
        minSdk = 23
        targetSdk = 33
        versionCode = 1 // ou flutter.versionCode se estiver definido
        versionName = "1.0.0" // ou flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    // Adicione aqui suas outras dependências do Firebase, por exemplo:
    // implementation("com.google.firebase:firebase-analytics")
}
