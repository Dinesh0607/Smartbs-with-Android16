package com.smartbs

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val textView = TextView(this)
        textView.text = "Welcome to SmartBS"
        textView.textSize = 24f
        setContentView(textView)
    }
} 