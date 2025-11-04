//
//  ViewController.swift
//  SystemVoiceRecorder
//
//  Created by Touheed khan on 02/11/2025.
//
//  ViewController12.swift

//

import UIKit
import AVFoundation
import UniformTypeIdentifiers

//#if targetEnvironment(macCatalyst)
//import AppKit
//#endif

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

class ViewController: UIViewController {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!

    var firstTimeHaveRun: Bool = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecordingUI()
    }

    func loadRecordingUI() {
        recordButton.isHidden = false
        recordButton.setTitle("Tap to Record", for: .normal)
        playButton.isHidden = true
    }

    // MARK: - Button Actions
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        if firstTimeHaveRun == false {
            setUpSK()
            firstTimeHaveRun = true
        }
        if audioPlayer == nil {
            startPlayback()
        } else {
            finishPlayback()
        }
    }
    
    func setUpSK() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)

            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        } catch {
            showAlert(title: "Error", message: "Recording setup failed.")
        }
    }

    // MARK: - Recording

    func startRecording() {
        audioFilename = getDocumentsDirectory().appendingPathComponent("recording-\(Int(Date().timeIntervalSince1970)).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
            playButton.isHidden = true
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            playButton.setTitle("Play Your Recording", for: .normal)
            playButton.isHidden = false

            // ✅ Prompt user to export
            showSaveDialog(for: audioFilename)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            playButton.isHidden = true
            showAlert(title: "Error", message: "Recording failed.")
        }
    }

    // MARK: - Playback

    func startPlayback() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.play()
            playButton.setTitle("Stop Playback", for: .normal)
        } catch {
            showAlert(title: "Error", message: "Unable to play the recording.")
        }
    }

    func finishPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        playButton.setTitle("Play Your Recording", for: .normal)
    }

    // MARK: - Save Dialog (iOS + Mac Catalyst)

    private func showSaveDialog(for fileURL: URL) {
        let alert = UIAlertController(
            title: "Recording Saved 🎉",
            message: "Would you like to export your recording?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Export", style: .default) { _ in
            self.exportAudioFile(fileURL)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func exportAudioFile(_ fileURL: URL) {
        // Works for iOS and Mac Catalyst 14+
        if #available(iOS 14.0, macCatalyst 14.0, *) {
            let picker = UIDocumentPickerViewController(forExporting: [fileURL])
            picker.allowsMultipleSelection = false
            picker.shouldShowFileExtensions = true
            present(picker, animated: true)
        } else {
            showAlert(title: "Export Unsupported",
                      message: "Requires iOS 14 / macOS 14 or later.")
        }
    }




    // MARK: - Alerts

    private func showPermissionAlert() {
        showAlert(title: "Microphone Access Denied",
                  message: "Please allow microphone access in Settings to record audio.")
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - Delegates

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}


