package com.truestate.truestate.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.truestate.truestate.R

/**
 * Stoic quote widget for TrueState.
 * Displays motivational quotes with author attribution.
 * 
 * Data keys read from SharedPreferences:
 * - stoic_quote: String (the quote text)
 * - stoic_author: String (author attribution)
 */
class StoicWidgetProvider : AppWidgetProvider() {
    
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
            val componentName = android.content.ComponentName(context, StoicWidgetProvider::class.java)
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
            val quote = helper.getStoicQuote()
            val author = helper.getStoicAuthor()
            
            val views = RemoteViews(context.packageName, R.layout.widget_stoic)
            
            // Update the quote text
            views.setTextViewText(R.id.stoic_quote, "\"$quote\"")
            
            // Update the author text (with dash prefix if author exists)
            if (author.isNotBlank()) {
                views.setTextViewText(R.id.stoic_author, "— $author")
                views.setViewVisibility(R.id.stoic_author, android.view.View.VISIBLE)
            } else {
                views.setTextViewText(R.id.stoic_author, "")
                views.setViewVisibility(R.id.stoic_author, android.view.View.GONE)
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
                views.setOnClickPendingIntent(R.id.widget_stoic_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
