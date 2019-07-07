//
//  HIDDeviceMonitor.swift
//  USBDeviceSwift
//
//  Created by Kyle King on 6/6/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import IOKit.hid
import Foundation

class Manager {
    var wiimotes:[IOHIDDevice:Wiimote] = [:]
    
    @objc func start() {
        let hid = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        let matches = [
            [kIOHIDProductIDKey: 0x0306, kIOHIDVendorIDKey: 0x057e],
            [kIOHIDProductIDKey: 0x0306, kIOHIDVendorIDKey: 0x0330]
        ]
        
        IOHIDManagerSetDeviceMatchingMultiple(hid, matches as CFArray)
        IOHIDManagerScheduleWithRunLoop(hid, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue);
        IOHIDManagerOpen(hid, IOOptionBits(kIOHIDOptionsTypeNone));
        
        let added:IOHIDDeviceCallback = { context, status, sender, device in
            let this = unsafeBitCast(context, to: Manager.self)
            this.wiimotes[device] = Wiimote(device, number: this.wiimotes.count+1)
            print("\(this.wiimotes[device]!) added")
        }
        
        IOHIDManagerRegisterDeviceMatchingCallback(hid, added, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        let removed:IOHIDDeviceCallback = { context, status, sender, device in
            let this = unsafeBitCast(context, to: Manager.self)
            print("\(this.wiimotes[device]!) removed")
            this.wiimotes.removeValue(forKey: device)
        }
        
        IOHIDManagerRegisterDeviceRemovalCallback(hid, removed, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        RunLoop.current.run()
    }
}
