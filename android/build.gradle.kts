buildscript {
    repositories {
        google() // Google's Maven repository
        mavenCentral()
    }

    dependencies {
        classpath ("com.android.tools.build:gradle:8.0.1") // Phiên bản Gradle phù hợp
        classpath ("com.google.gms:google-services:4.4.2" )// Plugin Google Services

    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
