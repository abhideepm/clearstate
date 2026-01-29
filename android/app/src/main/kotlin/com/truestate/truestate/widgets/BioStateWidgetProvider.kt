package com.truestate.truestate.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.truestate.truestate.R

/**
 * BioState widget for TrueState.
 * Displays a biological recovery metric with label and progress bar.
 * 
 * Data keys read from SharedPreferences:
 * - biostate_label: String (e.g., "Dopamine", "Sleep Quality")
 * - biostate_value: Float (0.0 to 1.0 representing progress)
 */
class BioStateWidgetProvider : AppWidgetProvider() {
    
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
            val componentName = android.content.ComponentName(context, BioStateWidgetProvider::class.java)
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
            val label = helper.getBioStateLabel()
            val valuePercent = helper.getBioStateValueInt()
            
            val views = RemoteViews(context.packageName, R.layout.widget_bio_state)
            
            // Update the label text
            views.setTextViewText(R.id.biostate_label, label)
            
            // Update the progress bar
            views.setProgressBar(R.id.biostate_progress, 100, valuePercent, false)
            
            // Update the percentage text
            views.setTextViewText(R.id.biostate_percentage, "$valuePercent%")
            
            // Create pending intent to launch app when widget is tapped
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_biostate_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
