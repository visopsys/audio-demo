//
//  ViewController.swift
//  SimpleAudioRecordApp
//
//  Created by Touheed khan on 05/11/2025.
//

import Cocoa
import AVFoundation
import ScreenCaptureKit

@available(macOS 14.4, *)
class ViewController: NSViewController {

    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!

    private var audioManager: SystemAudioCaptureManager?
    private var tempFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startRecording(_ sender: Any) {
        // Create a temp file in tmp directory
        let tmpDir = FileManager.default.temporaryDirectory
        let tempURL = tmpDir.appendingPathComponent("SystemAudio_\(Int(Date().timeIntervalSince1970)).m4a")
        self.tempFileURL = tempURL

        audioManager = SystemAudioCaptureManager()
        audioManager?.outputURL = tempURL

        Task {
            await audioManager?.start()
        }

        startButton.isEnabled = false
        stopButton.isEnabled = true
    }

  
    @IBAction func stopRecording(_ sender: Any) {
        audioManager?.stop()
        startButton.isEnabled = true
        stopButton.isEnabled = false

        guard let tempURL = self.tempFileURL else { return }

        Task { @MainActor in
            await showSavePanel(for: tempURL)
        }
    }
    @MainActor
    func showSavePanel(for tempURL: URL) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["m4a"]
        savePanel.nameFieldStringValue = tempURL.lastPathComponent
        savePanel.canCreateDirectories = true

        let result = savePanel.runModal()
        if result == .OK, let finalURL = savePanel.url {
            do {
                try FileManager.default.moveItem(at: tempURL, to: finalURL)
                print("✅ Recording saved to:", finalURL.path)
            } catch {
                print("❌ Failed to move file:", error)
            }
        } else {
            // User cancelled
            print("Recording saved to temporary file:", tempURL.path)
        }
    }
    


    func stopIfRecording() {
        audioManager?.stop()
    }
}




