plugins {
    id("com.android.application")
    id("com.google.gms.google-services")  // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")  // Flutter
}

android {
    namespace = "com.example.planify"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.planify"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    // Firebase BoM (Bill of Materials) - Gerencia versões automaticamente
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.mlkit:smart-reply:17.0.4'

    // Dependências do ML Kit (use apenas as necessárias)
    implementation 'com.google.android.gms:play-services-mlkit-text-recognition:19.0.0' // OCR
    implementation 'com.google.android.gms:play-services-mlkit-face-detection:17.1.0'  // Detecção facial
    implementation 'com.google.mlkit:smart-reply:17.0.4'  // Respostas inteligentes

    // Se precisar de modelos customizados:
    implementation 'com.google.firebase:firebase-ml-modeldownloader:24.2.0'

}