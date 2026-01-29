package com.truestate.truestate.widgets

import android.content.Context
import android.content.SharedPreferences

/**
 * Helper class for reading widget data from SharedPreferences.
 * Works with home_widget Flutter package's default preference file.
 */
class WidgetDataHelper(context: Context) {
    
    companion object {
        // home_widget uses the app's package name + ".HomeWidgetPreferences"
        private const val PREFS_NAME = "HomeWidgetPreferences"
        
        // Battery Widget keys
        const val KEY_BATTERY_PROGRESS = "battery_progress"
        const val KEY_BATTERY_MODE = "battery_mode"
        const val KEY_BATTERY_STREAK = "battery_streak"
        
        // Stoic Widget keys
        const val KEY_STOIC_QUOTE = "stoic_quote"
        const val KEY_STOIC_AUTHOR = "stoic_author"
        
        // BioState Widget keys
        const val KEY_BIOSTATE_LABEL = "biostate_label"
        const val KEY_BIOSTATE_VALUE = "biostate_value"
        
        // Widget colors (for reference in code)
        const val COLOR_BACKGROUND = 0xFF050505.toInt()
        const val COLOR_TEXT_PRIMARY = 0xFFE8E8E8.toInt()
        const val COLOR_TEXT_SECONDARY = 0xFF5C5C5C.toInt()
        const val COLOR_ACCENT = 0xFFFF6B35.toInt()
    }
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        PREFS_NAME,
        Context.MODE_PRIVATE
    )
    
    // Battery Widget getters
    fun getBatteryProgress(): Float {
        return prefs.getFloat(KEY_BATTERY_PROGRESS, 0f)
    }
    
    fun getBatteryProgressInt(): Int {
        return (getBatteryProgress() * 100).toInt().coerceIn(0, 100)
    }
    
    fun getBatteryMode(): String {
        return prefs.getString(KEY_BATTERY_MODE, "Battery") ?: "Battery"
    }
    
    fun getBatteryStreak(): Int {
        return prefs.getInt(KEY_BATTERY_STREAK, 0)
    }
    
    // Stoic Widget getters
    fun getStoicQuote(): String {
        return prefs.getString(KEY_STOIC_QUOTE, "Stay present. Stay strong.") ?: "Stay present. Stay strong."
    }
    
    fun getStoicAuthor(): String {
        return prefs.getString(KEY_STOIC_AUTHOR, "") ?: ""
    }
    
    // BioState Widget getters
    fun getBioStateLabel(): String {
        return prefs.getString(KEY_BIOSTATE_LABEL, "Recovery") ?: "Recovery"
    }
    
    fun getBioStateValue(): Float {
        return prefs.getFloat(KEY_BIOSTATE_VALUE, 0f)
    }
    
    fun getBioStateValueInt(): Int {
        return (getBioStateValue() * 100).toInt().coerceIn(0, 100)
    }
    
    /**
     * Generic getters for flexibility
     */
    fun getString(key: String, default: String = ""): String {
        return prefs.getString(key, default) ?: default
    }
    
    fun getInt(key: String, default: Int = 0): Int {
        return prefs.getInt(key, default)
    }
    
    fun getFloat(key: String, default: Float = 0f): Float {
        return prefs.getFloat(key, default)
    }
    
    fun getBoolean(key: String, default: Boolean = false): Boolean {
        return prefs.getBoolean(key, default)
    }
    
    fun getLong(key: String, default: Long = 0L): Long {
        return prefs.getLong(key, default)
    }
}
