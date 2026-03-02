package com.example.lets_talk

import android.app.Notification
import android.graphics.Bitmap
import android.graphics.drawable.Icon
import androidx.core.app.NotificationCompat

object NotificationHelper {
    fun createBigPictureStyle(
        bigPicture: Bitmap?,
        bigLargeIcon: Bitmap?,
        contentTitle: String?,
        summaryText: String?
    ): NotificationCompat.BigPictureStyle {
        val style = NotificationCompat.BigPictureStyle()
        
        if (bigPicture != null) {
            style.bigPicture(bigPicture)
        }
        
        if (bigLargeIcon != null) {
            style.bigLargeIcon(bigLargeIcon)
        }
        
        if (contentTitle != null) {
            style.setBigContentTitle(contentTitle)
        }
        
        if (summaryText != null) {
            style.setSummaryText(summaryText)
        }
        
        return style
    }
}
