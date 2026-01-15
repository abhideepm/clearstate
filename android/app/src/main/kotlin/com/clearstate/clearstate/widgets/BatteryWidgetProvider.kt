package com.clearstate.clearstate.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.clearstate.clearstate.R

/**
 * Battery-style circular progress widget for ClearState.
 * Displays sobriety progress as a battery/circular gauge.
 * 
 * Data keys read from SharedPreferences:
 * - battery_progress: Float (0.0 to 1.0)
 * - battery_mode: String (display label)
 * - battery_streak: Int (current streak days)
 */
class BatteryWidgetProvider : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // Handle home_widget update broadcasts
        if (intent.action == "es.antonborri.home_widget.action.UPDATE" ||
            intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, BatteryWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
    
    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val helper = WidgetDataHelper(context)
            val progress = helper.getBatteryProgressInt()
            val mode = helper.getBatteryMode()
            val streak = helper.getBatteryStreak()
            
            val views = RemoteViews(context.packageName, R.layout.widget_battery)
            
            // Update the progress indicator
            views.setProgressBar(R.id.battery_progress, 100, progress, false)
            
            // Update the percentage text
            views.setTextViewText(R.id.battery_percentage, "$progress%")
            
            // Update the mode/label text
            views.setTextViewText(R.id.battery_mode, mode)
            
            // Update streak if shown
            if (streak > 0) {
                views.setTextViewText(R.id.battery_streak, "Day $streak")
            } else {
                views.setTextViewText(R.id.battery_streak, "")
            }
            
            // Create pending intent to launch app when widget is tapped
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_battery_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
