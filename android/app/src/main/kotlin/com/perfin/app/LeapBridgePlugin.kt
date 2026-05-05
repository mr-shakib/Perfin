package com.perfin.app

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

// ─────────────────────────────────────────────────────────────────────────────
// LeapBridgePlugin — Flutter ↔ Liquid AI LEAP SDK bridge (Android)
//
// SETUP STEPS (before the on-device feature works):
//   1. Add the LEAP Android SDK to android/app/build.gradle:
//        dependencies {
//            implementation 'ai.liquid:leap-android:x.y.z'
//        }
//   2. Add the LEAP Maven repository to android/build.gradle if required.
//   3. Uncomment the `import ai.liquid.leap.*` line below.
//   4. Uncomment the LEAP-specific blocks marked TODO throughout this file.
//   5. Obtain a LEAP API key from https://leap.liquid.ai and store it securely
//        (e.g. BuildConfig or Android Keystore) then pass it when initialising
//        the ModelRunner.
// ─────────────────────────────────────────────────────────────────────────────

// import ai.liquid.leap.*  // TODO: uncomment after adding LEAP SDK dependency

class LeapBridgePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    // TODO: replace Any with ai.liquid.leap.ModelRunner once SDK is added.
    private var modelRunner: Any? = null
    private var eventSink: EventChannel.EventSink? = null

    private val scope = CoroutineScope(Dispatchers.IO)

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "com.perfin.app/leap")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "com.perfin.app/leap_stream")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // ── MethodCallHandler ─────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadModel" -> {
                val path = call.argument<String>("path")
                    ?: return result.error("INVALID_ARGS", "path required", null)
                loadModel(path, result)
            }
            "unloadModel" -> {
                modelRunner = null
                result.success(null)
            }
            "complete" -> {
                val prompt = call.argument<String>("prompt")
                    ?: return result.error("INVALID_ARGS", "prompt required", null)
                val maxTokens = call.argument<Int>("maxTokens") ?: 512
                val temperature = call.argument<Double>("temperature") ?: 0.7
                complete(prompt, maxTokens, temperature, result)
            }
            "completeStream" -> {
                val prompt = call.argument<String>("prompt")
                    ?: return result.error("INVALID_ARGS", "prompt required", null)
                val maxTokens = call.argument<Int>("maxTokens") ?: 512
                val temperature = call.argument<Double>("temperature") ?: 0.7
                completeStream(prompt, maxTokens, temperature)
                result.success(null)
            }
            "getModelInfo" -> {
                if (modelRunner == null) {
                    result.success(mapOf("loaded" to false))
                } else {
                    // TODO: return real metadata from LEAP SDK.
                    result.success(mapOf("loaded" to true, "name" to "LFM2", "contextLength" to 32768))
                }
            }
            else -> result.notImplemented()
        }
    }

    // ── Model loading ─────────────────────────────────────────────────────────

    private fun loadModel(path: String, result: Result) {
        scope.launch {
            // TODO: replace stub with real LEAP SDK call:
            //
            // try {
            //     modelRunner = ModelRunner.fromPath(context, path)
            //     withContext(Dispatchers.Main) { result.success(mapOf("success" to true)) }
            // } catch (e: Exception) {
            //     withContext(Dispatchers.Main) {
            //         result.success(mapOf("success" to false, "error" to e.message))
            //     }
            // }
            //
            // STUB — succeeds if the file exists on disk:
            val fileExists = File(path).exists()
            withContext(Dispatchers.Main) {
                if (fileExists) {
                    modelRunner = path   // placeholder
                    result.success(mapOf("success" to true))
                } else {
                    result.success(mapOf("success" to false, "error" to "Model file not found at: $path"))
                }
            }
        }
    }

    // ── Inference ─────────────────────────────────────────────────────────────

    private fun complete(prompt: String, maxTokens: Int, temperature: Double, result: Result) {
        if (modelRunner == null) {
            result.success("Model is not loaded.")
            return
        }
        scope.launch {
            // TODO: replace stub with real LEAP SDK call:
            //
            // val runner = modelRunner as ModelRunner
            // val conversation = Conversation()
            // conversation.addMessage(Role.User, prompt)
            // val response = runner.generate(conversation, maxTokens = maxTokens)
            // withContext(Dispatchers.Main) { result.success(response.text) }
            //
            // STUB response for development:
            val stub = "[On-device stub] Received: \"${prompt.take(60)}…\""
            withContext(Dispatchers.Main) { result.success(stub) }
        }
    }

    private fun completeStream(prompt: String, maxTokens: Int, temperature: Double) {
        if (modelRunner == null) {
            eventSink?.success("[On-device] Model not loaded.")
            eventSink?.endOfStream()
            return
        }
        scope.launch {
            // TODO: replace stub with real LEAP streaming:
            //
            // val runner = modelRunner as ModelRunner
            // runner.generateStream(prompt, maxTokens).collect { token ->
            //     withContext(Dispatchers.Main) { eventSink?.success(token) }
            // }
            // withContext(Dispatchers.Main) { eventSink?.endOfStream() }
            //
            // STUB — emits prompt words one-by-one:
            val words = "[On-device stub] ${prompt.take(60)}".split(" ")
            for (word in words) {
                Thread.sleep(50)
                withContext(Dispatchers.Main) { eventSink?.success("$word ") }
            }
            withContext(Dispatchers.Main) { eventSink?.endOfStream() }
        }
    }

    // ── EventChannel.StreamHandler ────────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
