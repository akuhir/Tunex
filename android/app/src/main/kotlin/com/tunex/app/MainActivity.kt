package com.tunex.app

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service requires the launcher Activity to extend
// AudioServiceActivity (not a plain FlutterActivity) — it wires up the
// FlutterEngine the background AudioService needs to bind to. Using
// plain FlutterActivity here caused a runtime crash on AudioService.init:
// "The Activity class declared in your AndroidManifest.xml is wrong or
// has not provided the correct FlutterEngine."
class MainActivity : AudioServiceActivity()
