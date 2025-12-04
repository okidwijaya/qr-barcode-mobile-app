import java.io.FileInputStream
import java.util.Properties
import com.android.build.gradle.internal.dsl.SigningConfig
import com.android.build.api.dsl.ApplicationBuildType

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kitadev.qr_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.kitadev.qr_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode as Int
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (rootProject.file("key.properties").exists()) {
                val props = Properties()
                props.load(FileInputStream(rootProject.file("key.properties")))

                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
                storePassword = props.getProperty("storePassword")
                storeFile = rootProject.file(props.getProperty("storeFile"))
            }
        }
    }

    buildTypes {
        getByName("release") {
            (this as ApplicationBuildType).signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = true 
            isShrinkResources = true
            
           proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}