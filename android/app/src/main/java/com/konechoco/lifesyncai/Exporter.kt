package com.konechoco.lifesyncai

import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import com.konechoco.lifesyncai.data.Store
import java.io.File

/** Scrive il backup in un file temporaneo e apre il foglio di condivisione di Android. */
object Exporter {
    fun share(context: Context, csv: Boolean): Boolean = runCatching {
        val dir = File(context.cacheDir, "exports").apply { mkdirs() }
        val extension = if (csv) "csv" else "json"
        val file = File(dir, "LifeSync-backup-${Store.dayKey()}.$extension")
        file.writeText(if (csv) Store.exportCsv() else Store.exportJson())
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = if (csv) "text/csv" else "application/json"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(Intent.createChooser(intent, file.name))
        true
    }.getOrDefault(false)
}
