repositories {
    google()
    mavenCentral()
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    // Removed project.evaluationDependsOn(":app") as it is unnecessary and can cause configuration issues.
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
