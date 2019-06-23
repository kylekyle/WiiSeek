//
//  AppDelegate.swift
//  WiiSeek
//
//  Created by Kyle King on 6/16/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let manager = Manager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.manager.startSearch()
        
        // "Play" button clicked
        subscribe(.stopSearch) { (_) in
            self.manager.stopSearch()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.manager.cleanup()
    }
}

