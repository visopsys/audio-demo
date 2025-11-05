//
//  ParenntView.swift
//  SimpleAudioRecordApp
//
//  Created by Touheed khan on 05/11/2025.
//


import Cocoa
import AppKit

class ParenntView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    private func setupView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = .clear
        self.layer?.cornerRadius = 14
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.layer?.backgroundColor = CGColor.white
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.layer?.backgroundColor = .clear
    }
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
    }
    
}
