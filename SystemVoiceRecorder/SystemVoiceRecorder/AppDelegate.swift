//
//  AppDelegate.swift
//  SystemVoiceRecorder
//
//  Created by Touheed khan on 02/11/2025.
//
import UIKit
import CoreData
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {

          // Safe startup setup
          do {
              try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
              try AVAudioSession.sharedInstance().setActive(true)
          } catch {
              print("⚠️ Audio session setup failed: \(error)")
          }

          return true
      }
    

    
}
