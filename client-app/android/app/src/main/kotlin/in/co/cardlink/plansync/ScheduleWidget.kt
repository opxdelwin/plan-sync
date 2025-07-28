package `in`.co.cardlink.plansync

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import android.content.SharedPreferences

class ScheduleWidget : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_screen_widget)

            // Get data from Flutter using SharedPreferences.getString()
            // The key "scheduleData" should match what's saved from Flutter via HomeWidget.saveWidgetData
            val jsonData = widgetData.getString("scheduleData", null)

            // Default to loading state if no data is present or explicitly set
            var widgetState = "loading"
            if (jsonData != null) {
                try {
                    val jsonObject = JSONObject(jsonData)
                    widgetState = jsonObject.optString("widgetState", "loading") // Read the state from Flutter
                    val currentSubjectJson = jsonObject.optJSONObject("currentSubject")
                    val nextSubjectJson = jsonObject.optJSONObject("nextSubject")

                    // Set visibility based on state
                    when (widgetState) {
                        "loading" -> {
                            views.setViewVisibility(R.id.loading_state_layout, View.VISIBLE)
                            views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                            views.setViewVisibility(R.id.data_display_layout, View.GONE)
                        }
                        "empty" -> {
                            views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                            views.setViewVisibility(R.id.empty_state_layout, View.VISIBLE)
                            views.setViewVisibility(R.id.data_display_layout, View.GONE)
                        }
                        "data" -> {
                            views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                            views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                            views.setViewVisibility(R.id.data_display_layout, View.VISIBLE)

                            // Populate current subject
                            if (currentSubjectJson != null) {
                                val currentName = currentSubjectJson.optString("name", "N/A")
                                val currentRoom = currentSubjectJson.optString("room", "N/A")
                                val currentTimeRange = currentSubjectJson.optString("time", "N/A") // Directly get the consolidated time string

                                views.setTextViewText(R.id.current_subject_details, "$currentName ($currentRoom) - $currentTimeRange")
                            } else {
                                views.setTextViewText(R.id.current_subject_details, "No current class")
                            }

                            // Populate next subject
                            if (nextSubjectJson != null) {
                                val nextName = nextSubjectJson.optString("name", "N/A")
                                val nextRoom = nextSubjectJson.optString("room", "N/A")
                                val nextTimeRange = nextSubjectJson.optString("time", "N/A") // Directly get the consolidated time string

                                views.setTextViewText(R.id.next_subject_details, "$nextName ($nextRoom) - $nextTimeRange")
                            } else {
                                views.setTextViewText(R.id.next_subject_details, "No upcoming class")
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Log error and show empty state or default
                    println("Error parsing widget data: $e")
                    views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                    views.setViewVisibility(R.id.empty_state_layout, View.VISIBLE)
                    views.setViewVisibility(R.id.data_display_layout, View.GONE)
                }
            } else {
                // No data received from Flutter, show loading or empty
                views.setViewVisibility(R.id.loading_state_layout, View.VISIBLE)
                views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                views.setViewVisibility(R.id.data_display_layout, View.GONE)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
