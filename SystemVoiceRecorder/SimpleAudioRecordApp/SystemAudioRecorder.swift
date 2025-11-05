//
//  SystemAudioRecorder.swift
//  SimpleAudioRecordApp
//
//  Created by Sharukh khan on 05/11/2025.
//


import Foundation
import ScreenCaptureKit
import AVFoundation

@available(macOS 14.4, *)
class SystemAudioCaptureManager: NSObject, SCStreamOutput, SCStreamDelegate {

    var outputURL: URL?

    private var stream: SCStream?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var isRecording = false

    @MainActor
    func start() async {
        guard let outputURL else {
            print("❌ Output URL not set")
            return
        }

        do {
            // Request shareable content (for audio capture)
            let content = try await SCShareableContent.current
            guard let display = content.displays.first else {
                print("❌ No display available for capture")
                return
            }

            // Filter: capture full display (no video processing needed)
            let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])

            // Configure stream: audio only, system audio
            let config = SCStreamConfiguration()
            config.capturesAudio = true
            config.excludesCurrentProcessAudio = false
            if #available(macOS 15.0, *) {
                config.captureMicrophone = false
            } else {
                // Fallback on earlier versions
            }

            // Create stream
            stream = SCStream(filter: filter, configuration: config, delegate: self)

            // Prepare AVAssetWriter to save audio
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .m4a)
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 192000
            ]
            assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
            assetWriterInput?.expectsMediaDataInRealTime = true

            if let input = assetWriterInput, assetWriter?.canAdd(input) == true {
                assetWriter?.add(input)
            }

            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: .zero)

            // Add audio stream output
            let audioQueue = DispatchQueue(label: "SystemAudioQueue")
            try stream?.addStreamOutput(self, type: .audio, sampleHandlerQueue: audioQueue)

            // Start capture
            try await stream?.startCapture()
            isRecording = true
            print("🎙️ System audio recording started…")
        } catch {
            print("❌ Failed to start system audio recording:", error)
        }
    }

    func stop() {
        guard isRecording else { return }
        isRecording = false

        // Stop the stream
        stream?.stopCapture()

        // Finish writing file
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            if let url = self?.outputURL {
                print("✅ System audio saved at:", url.path)
            }
        }
    }

    // MARK: - SCStreamOutput Delegate
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        guard outputType == .audio,
              isRecording,
              let writerInput = assetWriterInput,
              let writer = assetWriter,
              writer.status == .writing else { return }

        if writerInput.isReadyForMoreMediaData {
            writerInput.append(sampleBuffer)
        }
    }
}
