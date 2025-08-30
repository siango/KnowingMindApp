plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    namespace = "com.siango.knowingmindapp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.siango.knowingmindapp"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"

        // ให้ placeholder ของ provider อิง applicationId ของแต่ละ variant
        manifestPlaceholders += mapOf("applicationId" to applicationId)
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug { isMinifyEnabled = false }
    }

    // ใช้อย่างน้อย ViewBinding (ถ้าใช้ Compose ค่อยเปิดทีหลัง)
    buildFeatures {
        viewBinding = true
        // compose = true
    }
    // ถ้าเปิด compose ให้กำหนด compiler extension ด้วย
    // composeOptions { kotlinCompilerExtensionVersion = "1.5.14" }

    flavorDimensions += "app"
    productFlavors {
        create("knowingMindApp") {
            dimension = "app"
            applicationIdSuffix = ".kma"
            resValue("string", "app_name", "KnowingMindApp")
        }
        create("arunroo") {
            dimension = "app"
            applicationIdSuffix = ".aru"
            resValue("string", "app_name", "ArunRoo")
        }
        create("satiShift") {
            dimension = "app"
            applicationIdSuffix = ".ssi"
            resValue("string", "app_name", "SatiShift")
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE", "META-INF/LICENSE.txt",
                "META-INF/license*",
                "META-INF/NOTICE", "META-INF/NOTICE.txt",
                "META-INF/ASL2.0"
            )
        }
    }
}

dependencies {
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:1.9.24"))
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // เปิดใช้ Compose เมื่อพร้อม
    // implementation("androidx.activity:activity-compose:1.9.2")
    // implementation("androidx.compose.ui:ui:1.7.2")
    // implementation("androidx.compose.ui:ui-tooling-preview:1.7.2")
    // implementation("androidx.compose.material3:material3:1.3.0")
    // debugImplementation("androidx.compose.ui:ui-tooling:1.7.2")
}
