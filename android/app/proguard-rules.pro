-keep class com.jellybuddy.** { *; }
-keep class io.flutter.** { *; }
# Keep llama.cpp JNI
-keep class com.jellybuddy.jelly_llm.LlamaBridge { *; }

# Flutter Play Store split compatibility
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# R8 missing classes workaround
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
