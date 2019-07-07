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
        Thread(
            target: self.manager,
            selector:#selector(self.manager.start),
            object: nil
        ).start()
    }
}
