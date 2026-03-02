package com.example.lets_talk

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
    }
    
    override fun attachBaseContext(base: android.content.Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
