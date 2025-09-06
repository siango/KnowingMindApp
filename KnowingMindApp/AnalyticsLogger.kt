package com.knowingmind.app.analytics

import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics

class AnalyticsLogger(private val firebaseAnalytics: FirebaseAnalytics) {

    fun logPracticeStart(origin: String, surface: String) {
        val params = Bundle().apply {
            putString("origin", origin)
            putString("surface", surface)
        }
        firebaseAnalytics.logEvent("practice_start", params)
    }

    fun logPracticeComplete(durationMs: Long, streak: Int) {
        val params = Bundle().apply {
            putLong("duration_ms", durationMs)
            putInt("streak", streak)
        }
        firebaseAnalytics.logEvent("practice_complete", params)
    }

    fun logShareCard(channel: String) {
        val params = Bundle().apply {
            putString("channel", channel)
        }
        firebaseAnalytics.logEvent("share_card", params)
    }

    fun logBookOpen(bookId: String, page: Int) {
        val params = Bundle().apply {
            putString("book_id", bookId)
            putInt("page", page)
        }
        firebaseAnalytics.logEvent("book_open", params)
    }

    fun logChantPlay(chantId: String, seconds: Int) {
        val params = Bundle().apply {
            putString("chant_id", chantId)
            putInt("seconds", seconds)
        }
        firebaseAnalytics.logEvent("chant_play", params)
    }

    fun logDonationInitiated(method: String) {
        val params = Bundle().apply {
            putString("method", method)
        }
        firebaseAnalytics.logEvent("donation_initiated", params)
    }

    fun logDonationSuccess(amount: Double, currency: String) {
        val params = Bundle().apply {
            putDouble("amount", amount)
            putString("currency", currency)
        }
        firebaseAnalytics.logEvent("donation_success", params)
    }
}
