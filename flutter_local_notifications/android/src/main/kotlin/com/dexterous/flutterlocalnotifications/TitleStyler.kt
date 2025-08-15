package com.dexterous.flutterlocalnotifications

import android.content.Context
import android.graphics.Typeface
import android.os.Build
import android.text.SpannableString
import android.text.Spanned
import android.text.style.StyleSpan
import android.util.Log
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import com.dexterous.flutterlocalnotifications.models.TitleStyle

internal object TitleStyler {
  private const val TAG = "TitleStyler"
  private const val MAX_SIZE_SP = 26f
  private const val MIN_SIZE_SP = 8f

  
    // Builds a RemoteViews that renders a styled title (and optional body).
    // API 24+ only. Returns null if title is empty or style is null.
   
  fun build(
    context: Context,
    title: CharSequence?,
    // NEW: body text to render below the title (default styling)
    body: CharSequence?,
    style: TitleStyle?
  ): RemoteViews? {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return null
    if (title.isNullOrEmpty() || style == null) return null

    val rv = RemoteViews(context.packageName, R.layout.fln_notif_title_only)
    val titleId = R.id.fln_title
    val bodyId = R.id.fln_body

    // 1) Build styled title (bold/italic via spans)
    val styled: CharSequence = if ((style.bold == true) || (style.italic == true)) {
      val s = SpannableString(title)
      when {
        style.bold == true && style.italic == true ->
          s.setSpan(StyleSpan(Typeface.BOLD_ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        style.bold == true ->
          s.setSpan(StyleSpan(Typeface.BOLD), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        style.italic == true ->
          s.setSpan(StyleSpan(Typeface.ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }
      s
    } else {
      title
    }

    // Apply title color/size
    style.color?.let { rv.setTextColor(titleId, it) }
    style.sizeSp?.let {
      if (it > 0.0) {
        val sp = it.toFloat().coerceIn(MIN_SIZE_SP, MAX_SIZE_SP)
        rv.setTextViewTextSize(titleId, TypedValue.COMPLEX_UNIT_SP, sp)
      } else {
        Log.d(TAG, "Ignoring non-positive sizeSp: $it")
      }
    }

    // Set title last (ensures spans + color/size stick)
    rv.setTextViewText(titleId, styled)

    // 2) Body/description (default appearance), only if provided
    if (!body.isNullOrEmpty()) {
      rv.setViewVisibility(bodyId, View.VISIBLE)
      rv.setTextViewText(bodyId, body)
      // We intentionally don't override color/size: let system theme handle it
    } else {
      rv.setViewVisibility(bodyId, View.GONE)
    }
    return rv
  }
}
