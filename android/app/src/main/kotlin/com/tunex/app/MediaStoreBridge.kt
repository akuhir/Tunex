package com.tunex.app

import android.content.ContentUris
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger

class MediaStoreBridge(private val messenger: BinaryMessenger, private val activityProvider: () -> android.app.Activity?) {
    companion object { const val CHANNEL = "com.tunex.app/media_store" }

    fun register() {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            val activity = activityProvider()
            if (activity == null) { result.error("NO_ACTIVITY", "Activity unavailable", null); return@setMethodCallHandler }
            try {
                when (call.method) {
                    "scanLibrary" -> result.success(scanLibrary(activity))
                    "getArtwork" -> {
                        val id = (call.argument<Number>("id") ?: 0).toLong()
                        val album = call.argument<Boolean>("album") ?: false
                        result.success(getArtwork(activity, id, album))
                    }
                    else -> result.notImplemented()
                }
            } catch (t: Throwable) {
                result.error("MEDIA_STORE_ERROR", t.message, null)
            }
        }
    }

    private fun scanLibrary(activity: android.app.Activity): Map<String, Any> {
        val songs = mutableListOf<Map<String, Any?>>()
        val albumMap = linkedMapOf<Long, MutableMap<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.IS_MUSIC,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DATE_ADDED
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sort = "${MediaStore.Audio.Media.DATE_ADDED} DESC, ${MediaStore.Audio.Media._ID} DESC"
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        activity.contentResolver.query(uri, projection, selection, null, sort)?.use { c ->
            val idCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val albumIdCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val artistIdCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST_ID)
            val durationCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val dataCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val dateAddedCol = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
            while (c.moveToNext()) {
                val id = c.getLong(idCol)
                val albumId = c.getLong(albumIdCol)
                val artistId = c.getLong(artistIdCol)
                val title = c.getString(titleCol) ?: "Unknown Title"
                val artist = (c.getString(artistCol) ?: "Unknown Artist").let { if (it == "<unknown>") "Unknown Artist" else it }
                val album = (c.getString(albumCol) ?: "Unknown Album").let { if (it == "<unknown>") "Unknown Album" else it }
                val duration = c.getLong(durationCol)
                val path = c.getString(dataCol) ?: ""
                val dateAdded = c.getLong(dateAddedCol)
                if (duration <= 15000) continue
                val ext = path.substringAfterLast('.', "").lowercase()
                if (ext !in setOf("mp3", "wav", "flac", "aac", "ogg", "m4a")) continue

                songs += mapOf("id" to id, "title" to title, "artist" to artist, "album" to album,
                    "albumId" to albumId, "artistId" to artistId, "duration" to duration, "path" to path,
                    "dateAdded" to dateAdded)

                val existing = albumMap[albumId]
                if (existing == null) albumMap[albumId] = mutableMapOf(
                    "id" to albumId, "title" to album, "artist" to artist, "numberOfSongs" to 1
                ) else existing["numberOfSongs"] = (existing["numberOfSongs"] as Int) + 1
            }
        }
        return mapOf("songs" to songs, "albums" to albumMap.values.toList())
    }

    private fun getArtwork(activity: android.app.Activity, id: Long, album: Boolean): ByteArray? {
        val albumId = if (album) id else {
            var found = -1L
            val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
            activity.contentResolver.query(uri, arrayOf(MediaStore.Audio.Media.ALBUM_ID), null, null, null)?.use { c ->
                if (c.moveToFirst()) found = c.getLong(0)
            }
            found
        }
        if (albumId < 0) return null
        val artUri = ContentUris.withAppendedId(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI, albumId)
            .buildUpon().appendPath("albumart").build()
        return try { activity.contentResolver.openInputStream(artUri)?.use { it.readBytes() } } catch (_: Throwable) { null }
    }
}
