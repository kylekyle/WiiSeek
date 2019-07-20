//
//  HIDDeviceMonitor.swift
//  USBDeviceSwift
//
//  Created by Kyle King on 6/6/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import IOKit.hid
import Foundation

class Monitor {
    var wiimotes:[IOHIDDevice:Wiimote] = [:]
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    
    init() {
        let matches = [
            [kIOHIDProductIDKey: 0x0306, kIOHIDVendorIDKey: 0x057e],
            [kIOHIDProductIDKey: 0x0306, kIOHIDVendorIDKey: 0x0330]
        ]
        
        IOHIDManagerSetDeviceMatchingMultiple(self.manager, matches as CFArray)
        
        IOHIDManagerScheduleWithRunLoop(
            self.manager,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
        
        IOHIDManagerOpen(self.manager, IOOptionBits(kIOHIDOptionsTypeNone))
        
        let added:IOHIDDeviceCallback = { context, status, sender, device in
            let this = unsafeBitCast(context, to: Monitor.self)
            this.wiimotes[device] = Wiimote(device, number: this.wiimotes.count+1)
            print("\(this.wiimotes[device]!) added")
        }
        
        IOHIDManagerRegisterDeviceMatchingCallback(self.manager, added, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        let removed:IOHIDDeviceCallback = { context, status, sender, device in
            let this = unsafeBitCast(context, to: Monitor.self)
            print("\(this.wiimotes[device]!) removed")
            this.wiimotes.removeValue(forKey: device)
        }
        
        IOHIDManagerRegisterDeviceRemovalCallback(self.manager, removed, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }
    
    func start() {
        // this is probably NOT the way to do it ...
        Thread(block:{RunLoop.current.run()}).start()
    }
    
    func stop() {
        print("Shutting down ...")
        
        for (device,_) in wiimotes {
            wiimotes.removeValue(forKey: device)
        }
    }
}
