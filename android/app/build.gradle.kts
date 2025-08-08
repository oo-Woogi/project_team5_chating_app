plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_team5_chating_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // NDK 버전 업데이트

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.project_team5_chating_app"
        minSdk = 23 // 최소 SDK 버전 23으로 업데이트
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 선택: 릴리스 빌드용 서명 설정
    signingConfigs {
        create("release") {
            // TODO: 실제 키스토어 정보로 대체
            storeFile = file("path/to/keystore.jks")
            storePassword = "your-store-password"
            keyAlias = "your-key-alias"
            keyPassword = "your-key-password"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// 선택: Firebase 종속성 추가
dependencies {
    // 예: implementation("com.google.firebase:firebase-analytics-ktx:21.3.0")
}