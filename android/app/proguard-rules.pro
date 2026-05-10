# Google ML Kit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keepclassmembers class com.google.mlkit.vision.text.** { *; }

# Google ML Kit Common
-keep class com.google.mlkit.common.** { *; }
-keepclassmembers class com.google.mlkit.common.** { *; }

# Suppress warnings for optional ML Kit language modules that might not be included
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Suppress all other warnings
-ignorewarnings
