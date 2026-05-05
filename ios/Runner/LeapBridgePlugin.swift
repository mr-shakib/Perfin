import Flutter
import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// LeapBridgePlugin — Flutter ↔ Liquid AI LEAP SDK bridge (iOS)
//
// SETUP STEPS (before the on-device feature works):
//   1. Add the LEAP iOS SDK via Swift Package Manager in Xcode:
//        File → Add Package Dependencies
//        URL: https://github.com/liquid-ai/leap-swift (replace with real URL)
//   2. Uncomment the `import LEAP` line below.
//   3. Uncomment the LEAP-specific blocks marked TODO throughout this file.
//   4. Obtain a LEAP API key from https://leap.liquid.ai and add it to Info.plist
//        or pass it as an initialisation argument.
// ─────────────────────────────────────────────────────────────────────────────

// import LEAP  // TODO: uncomment after adding the Swift Package

class LeapBridgePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    // MARK: - Registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.perfin.app/leap",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.perfin.app/leap_stream",
            binaryMessenger: registrar.messenger()
        )

        let instance = LeapBridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - State

    // TODO: replace Any with the real LEAP ModelRunner type once SDK is added.
    private var modelRunner: Any? = nil
    private var eventSink: FlutterEventSink? = nil

    // MARK: - MethodChannel handler

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "loadModel":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
                return
            }
            loadModel(path: path, result: result)

        case "unloadModel":
            modelRunner = nil
            result(nil)

        case "complete":
            guard let args = call.arguments as? [String: Any],
                  let prompt = args["prompt"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "prompt required", details: nil))
                return
            }
            let maxTokens = args["maxTokens"] as? Int ?? 512
            let temperature = args["temperature"] as? Double ?? 0.7
            complete(prompt: prompt, maxTokens: maxTokens, temperature: temperature, result: result)

        case "completeStream":
            guard let args = call.arguments as? [String: Any],
                  let prompt = args["prompt"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "prompt required", details: nil))
                return
            }
            let maxTokens = args["maxTokens"] as? Int ?? 512
            let temperature = args["temperature"] as? Double ?? 0.7
            completeStream(prompt: prompt, maxTokens: maxTokens, temperature: temperature)
            result(nil)

        case "getModelInfo":
            guard modelRunner != nil else {
                result(["loaded": false])
                return
            }
            // TODO: return real model metadata from LEAP SDK.
            result(["loaded": true, "name": "LFM2", "contextLength": 32768])

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Model loading

    private func loadModel(path: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            // TODO: replace stub with real LEAP SDK call:
            //
            // do {
            //     self.modelRunner = try ModelRunner(modelPath: path)
            //     DispatchQueue.main.async { result(["success": true]) }
            // } catch {
            //     DispatchQueue.main.async {
            //         result(["success": false, "error": error.localizedDescription])
            //     }
            // }
            //
            // STUB — succeeds without a real model so Dart UI can be tested:
            let fileExists = FileManager.default.fileExists(atPath: path)
            DispatchQueue.main.async {
                if fileExists {
                    self.modelRunner = path  // placeholder
                    result(["success": true])
                } else {
                    result(["success": false, "error": "Model file not found at: \(path)"])
                }
            }
        }
    }

    // MARK: - Inference

    private func complete(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        result: @escaping FlutterResult
    ) {
        guard modelRunner != nil else {
            result("Model is not loaded.")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            // TODO: replace stub with real LEAP SDK call:
            //
            // let runner = self.modelRunner as! ModelRunner
            // let conversation = Conversation()
            // conversation.addMessage(role: .user, content: prompt)
            // let response = try await runner.generate(conversation, maxTokens: maxTokens)
            // DispatchQueue.main.async { result(response.text) }
            //
            // STUB response for development:
            let stub = "[On-device stub] Received: \"\(prompt.prefix(60))…\""
            DispatchQueue.main.async { result(stub) }
        }
    }

    private func completeStream(prompt: String, maxTokens: Int, temperature: Double) {
        guard modelRunner != nil else {
            eventSink?("[On-device] Model not loaded.")
            eventSink?(FlutterEndOfEventStream)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            // TODO: replace stub with real LEAP streaming:
            //
            // let runner = self.modelRunner as! ModelRunner
            // for try await token in runner.generateStream(prompt, maxTokens: maxTokens) {
            //     DispatchQueue.main.async { self.eventSink?(token) }
            // }
            // DispatchQueue.main.async { self.eventSink?(FlutterEndOfEventStream) }
            //
            // STUB — emits the prompt back word-by-word:
            let words = "[On-device stub] \(prompt.prefix(60))".split(separator: " ")
            for word in words {
                Thread.sleep(forTimeInterval: 0.05)
                DispatchQueue.main.async { self.eventSink?(String(word) + " ") }
            }
            DispatchQueue.main.async { self.eventSink?(FlutterEndOfEventStream) }
        }
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
