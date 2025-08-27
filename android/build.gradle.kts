// android/build.gradle.kts (project-level)

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/** ✅ 플러그인들이 읽을 ext 값만 제공 (compileSdk 직접 세팅은 하지 않음) */
extra.apply {
    set("compileSdkVersion", 34)
    set("compileSdk", 34)          // 어떤 플러그인은 이 키를 참조
    set("minSdkVersion", 21)
    set("minSdk", 21)
    set("targetSdkVersion", 34)
    set("targetSdk", 34)
}

/** (선택) 커스텀 빌드 디렉토리 유지 */
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

/** ✅ 공통: Kotlin jvmTarget만 각 모듈의 Java 타깃에 “읽어서” 맞춤 (compileOptions/compileSdk는 손대지 않음) */
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        // 각 모듈의 android { compileOptions.targetCompatibility }를 Provider로 "읽기만" 합니다.
        val javaTargetProvider = providers.provider {
            val libExt = extensions.findByType(
                com.android.build.api.dsl.LibraryExtension::class.java
            )
            val appExt = extensions.findByType(
                com.android.build.api.dsl.ApplicationExtension::class.java
            )
            libExt?.compileOptions?.targetCompatibility
                ?: appExt?.compileOptions?.targetCompatibility
                ?: JavaVersion.VERSION_11 // 기본값 (camera와 맞춤)
        }

        // Kotlin 컴파일 태스크에 jvmTarget을 설정 (afterEvaluate 사용하지 않음)
        tasks.withType(KotlinCompile::class.java).configureEach {
            // Kotlin 2.x 경로: Property에 Provider를 그대로 연결
            try {
                @Suppress("DEPRECATION")
                compilerOptions.jvmTarget.set(
                    javaTargetProvider.map {
                        when (it) {
                            JavaVersion.VERSION_21 -> JvmTarget.JVM_21
                            JavaVersion.VERSION_17 -> JvmTarget.JVM_17
                            JavaVersion.VERSION_11 -> JvmTarget.JVM_11
                            else -> JvmTarget.JVM_1_8
                        }
                    }
                )
            } catch (_: Throwable) {
                // Kotlin 1.9.x 호환 경로: 즉시 계산해서 문자열로 지정
                val jt = when (javaTargetProvider.get()) {
                    JavaVersion.VERSION_21 -> "21"
                    JavaVersion.VERSION_17 -> "17"
                    JavaVersion.VERSION_11 -> "11"
                    else -> "1.8"
                }
                kotlinOptions.jvmTarget = jt
            }
        }
    }
}

// --- namespace auto-fill for Android library modules (e.g. gallery_saver) ---
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension> {
            if (namespace.isNullOrBlank()) {
                val manifest = file("src/main/AndroidManifest.xml")
                val fallbackNs =
                    "com.${rootProject.name.replace('-', '_')}." +
                            project.name.replace('-', '_')

                if (manifest.exists()) {
                    val pkg = Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifest.readText())
                        ?.groupValues?.getOrNull(1)

                    namespace = if (!pkg.isNullOrBlank()) pkg else fallbackNs
                } else {
                    namespace = fallbackNs
                }
                println("\uD83D\uDDA4 Set namespace for ${project.name} -> $namespace")
            }
        }
    }
}


/** clean */
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
