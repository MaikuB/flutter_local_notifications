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
import com.dexterous.flutterlocalnotifications.models.DescriptionStyle

internal object TitleStyler {
  private const val TAG = "TitleStyler"
  private const val MAX_SIZE_SP = 26f
  private const val MIN_SIZE_SP = 8f

  
    // Builds a RemoteViews that renders a styled title (and optional body).
    // API 24+ only. Returns null if title is empty or style is null.

  fun build(
    context: Context,
    title: CharSequence?,
    body: CharSequence?,
    titleStyle: TitleStyle?,
    descriptionStyle: DescriptionStyle?
  ): RemoteViews? {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return null
    if (title.isNullOrEmpty()) return null
    if (titleStyle == null && descriptionStyle == null) return null

    val rv = RemoteViews(context.packageName, R.layout.fln_notif_title_only)
    val titleId = R.id.fln_title
    val bodyId = R.id.fln_body
    val rootId = R.id.fln_root

    // Build styled title (bold/italic via spans)
     val styledTitle: CharSequence = if ((titleStyle?.bold == true) || (titleStyle?.italic == true)) {
      val s = SpannableString(title)
      when {
        titleStyle.bold == true && titleStyle.italic == true ->
          s.setSpan(StyleSpan(Typeface.BOLD_ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        titleStyle.bold == true ->
          s.setSpan(StyleSpan(Typeface.BOLD), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        titleStyle.italic == true ->
          s.setSpan(StyleSpan(Typeface.ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
      }
      s
    } else {
      title
    }

    // Apply title color/size
    titleStyle?.color?.let { rv.setTextColor(titleId, it) }
    titleStyle?.sizeSp?.let {
      if (it > 0.0) {
        val sp = it.toFloat().coerceIn(MIN_SIZE_SP, MAX_SIZE_SP)
        rv.setTextViewTextSize(titleId, TypedValue.COMPLEX_UNIT_SP, sp)
      } else {
        Log.d(TAG, "Ignoring non-positive sizeSp: $it")
      }
    }

    // Set title last (ensures spans + color/size stick)
    rv.setTextViewText(titleId, styledTitle)

// Adjust spacing between icon and text if requested (RTL-safe)
titleStyle?.iconSpacingDp?.let { spacing ->
  if (spacing >= 0) {
    val metrics = context.resources.displayMetrics
    val startPx = TypedValue.applyDimension(
      TypedValue.COMPLEX_UNIT_DIP,
      spacing.toFloat(),
      metrics
    ).toInt()

    // Defaults from resources (match XML)
    val defaultStart = context.resources.getDimensionPixelSize(R.dimen.fln_padding_start)
    val defaultTop = context.resources.getDimensionPixelSize(R.dimen.fln_padding_top)
    val defaultEnd = context.resources.getDimensionPixelSize(R.dimen.fln_padding_end)
    val defaultBottom = context.resources.getDimensionPixelSize(R.dimen.fln_padding_bottom)

    val isRtl = context.resources.configuration.layoutDirection == View.LAYOUT_DIRECTION_RTL

    val left = if (isRtl) defaultStart else startPx
    val right = if (isRtl) startPx else defaultEnd

    rv.setViewPadding(rootId, left, defaultTop, right, defaultBottom)
  } else {
    Log.d(TAG, "Ignoring negative iconSpacingDp: $spacing")
  }
}

    // Body/description styled if provided
    if (!body.isNullOrEmpty()) {
      val styledBody: CharSequence = if ((descriptionStyle?.bold == true) || (descriptionStyle?.italic == true)) {
        val s = SpannableString(body)
        when {
          descriptionStyle.bold == true && descriptionStyle.italic == true ->
            s.setSpan(StyleSpan(Typeface.BOLD_ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
          descriptionStyle.bold == true ->
            s.setSpan(StyleSpan(Typeface.BOLD), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
          descriptionStyle.italic == true ->
            s.setSpan(StyleSpan(Typeface.ITALIC), 0, s.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
        s
      } else {
        body
      }

      descriptionStyle?.color?.let { rv.setTextColor(bodyId, it) }
      descriptionStyle?.sizeSp?.let {
        if (it > 0.0) {
          val sp = it.toFloat().coerceIn(MIN_SIZE_SP, MAX_SIZE_SP)
          rv.setTextViewTextSize(bodyId, TypedValue.COMPLEX_UNIT_SP, sp)
        } else {
          Log.d(TAG, "Ignoring non-positive sizeSp: $it")
        }
      }

      rv.setViewVisibility(bodyId, View.VISIBLE)
      rv.setTextViewText(bodyId, styledBody)
    } else {
      rv.setViewVisibility(bodyId, View.GONE)
    }
    return rv
  }
}
