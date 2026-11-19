package com.konechoco.lifesyncai

import android.content.Context

/** Riepilogo giornaliero generato in locale sui dati reali della giornata (nessun dato lascia il telefono). */
object Summary {
    fun make(context: Context, steps: Int, places: Int, averageSteps: Int?, notes: Int): String {
        val lines = mutableListOf(
            context.getString(R.string.sum_steps_line, steps),
            context.getString(R.string.sum_places_line, places),
        )
        if (notes > 0) lines += context.getString(R.string.sum_notes_line, notes)

        if (averageSteps != null && averageSteps > 0) {
            val diff = ((steps - averageSteps).toDouble() / averageSteps * 100).toInt()
            lines += when {
                diff >= 5 -> context.getString(R.string.sum_above, diff)
                diff <= -5 -> context.getString(R.string.sum_below, -diff)
                else -> context.getString(R.string.sum_same)
            }
        } else {
            lines += context.getString(R.string.sum_first)
        }

        lines += context.getString(if (steps >= 8000) R.string.sum_close_active else R.string.sum_close_light)
        return context.getString(R.string.sum_header) + "\n\n" + lines.joinToString("\n")
    }
}
