package com.tunex.app

import com.ryanheise.audioservice.AudioServiceActivity
import android.content.Intent
import androidx.core.content.FileProvider
import java.io.File

class MainActivity : AudioServiceActivity() {
    private var mediaStoreBridge: MediaStoreBridge? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaStoreBridge = MediaStoreBridge(flutterEngine.dartExecutor.binaryMessenger) { this }
        mediaStoreBridge?.register()
        io.flutter.plugin.common.MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, "com.tunex.app/share"
        ).setMethodCallHandler { call, result ->
            if (call.method != "shareFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path.isNullOrBlank()) {
                result.error("INVALID_PATH", "No file path supplied", null)
                return@setMethodCallHandler
            }
            try {
                val file = File(path)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "Audio file not found", null)
                    return@setMethodCallHandler
                }
                val uri = FileProvider.getUriForFile(
                    this, "${applicationContext.packageName}.fileprovider", file
                )
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "audio/*"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivity(Intent.createChooser(intent, "Share song"))
                result.success(true)
            } catch (t: Throwable) {
                result.error("SHARE_FAILED", t.message, null)
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        mediaStoreBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
