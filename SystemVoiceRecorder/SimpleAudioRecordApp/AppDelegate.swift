//
//  AppDelegate.swift
//  SimpleAudioRecordApp
//
//  Created by Touheed khan on 05/11/2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // No manual window creation needed
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let viewController = NSApp.mainWindow?.contentViewController as? ViewController {
            viewController.stopIfRecording()
        }
    }
}



