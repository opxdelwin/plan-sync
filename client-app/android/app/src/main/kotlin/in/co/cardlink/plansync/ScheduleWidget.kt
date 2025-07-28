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



            val jsonData = widgetData.getString("scheduleData", null)

            // Determine the widget state based on configuration first, then data availability
            var widgetState: String // This variable will hold the determined state
             if (jsonData != null) {
                println("[x] Received widget data: $jsonData")
                try {
                    val jsonObject = JSONObject(jsonData)
                    widgetState = jsonObject.optString("widgetState", "loading")
                } catch (e: Exception) {
                    println("Error parsing widget data: $e")
                    widgetState = "empty" // Fallback if JSON is corrupt
                }
            } else {
                widgetState = "unconfigured"
            }

            // --- END NEW ---

            // Set visibility based on the determined state
            when (widgetState) {
                "loading" -> {
                    views.setViewVisibility(R.id.loading_state_layout, View.VISIBLE)
                    views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                    views.setViewVisibility(R.id.data_display_layout, View.GONE)
                    views.setViewVisibility(R.id.configuration_required_layout, View.GONE)
                }
                "empty" -> {
                    views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                    views.setViewVisibility(R.id.empty_state_layout, View.VISIBLE)
                    views.setViewVisibility(R.id.data_display_layout, View.GONE)
                    views.setViewVisibility(R.id.configuration_required_layout, View.GONE)
                }
                "unconfigured" -> {
                    views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                    views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                    views.setViewVisibility(R.id.data_display_layout, View.GONE)
                    views.setViewVisibility(R.id.configuration_required_layout, View.VISIBLE)
                }
                "data" -> {
                    views.setViewVisibility(R.id.loading_state_layout, View.GONE)
                    views.setViewVisibility(R.id.empty_state_layout, View.GONE)
                    views.setViewVisibility(R.id.data_display_layout, View.VISIBLE)
                    views.setViewVisibility(R.id.configuration_required_layout, View.GONE)

                    // Populate data only if the state is "data"
                    val jsonObject = JSONObject(jsonData!!) // jsonData is guaranteed not null here

                    val currentSubjectJson = jsonObject.optJSONObject("currentSubject")
                    val nextSubjectJson = jsonObject.optJSONObject("nextSubject")

                    if (currentSubjectJson != null) {
                        val currentName = currentSubjectJson.optString("name", "N/A")
                        val currentRoom = currentSubjectJson.optString("room", "N/A")
                        val currentTimeRange = currentSubjectJson.optString("time", "N/A")
                        views.setTextViewText(R.id.current_subject_details, "$currentName ($currentRoom) - $currentTimeRange")
                    } else {
                        views.setTextViewText(R.id.current_subject_details, "No current class")
                    }

                    if (nextSubjectJson != null) {
                        val nextName = nextSubjectJson.optString("name", "N/A")
                        val nextRoom = nextSubjectJson.optString("room", "N/A")
                        val nextTimeRange = nextSubjectJson.optString("time", "N/A")
                        views.setTextViewText(R.id.next_subject_details, "$nextName ($nextRoom) - $nextTimeRange")
                    } else {
                        views.setTextViewText(R.id.next_subject_details, "No upcoming class")
                    }
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}