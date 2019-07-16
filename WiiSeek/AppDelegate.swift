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
    var thread: Thread?
    var monitor: Monitor = Monitor()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("terminating")
        monitor.stop()
    }
}
