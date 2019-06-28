//
//  Manager.swift
//  WiiSeek
//
//  Created by Kyle King on 6/19/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Foundation
import IOBluetooth

// someone's got to manage these wiimotes
class Manager: IOBluetoothDeviceInquiryDelegate {
    let maxWiimotes = 4
    var wiimotes: [Wiimote] = []
    var inquiry = IOBluetoothDeviceInquiry()

    func startSearch() {
        inquiry.delegate = self
        inquiry.updateNewDeviceNames = true

        guard inquiry.start() == kIOReturnSuccess else {
            log("The Bluetooth module is off or unresponsive")
            return
        }
    }

    func stopSearch() {
        self.inquiry.stop()
        self.inquiry.delegate = nil
    }

    func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry!) {
        log("Searching for wiimotes ...")
    }

    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry, device: IOBluetoothDevice) {
        guard device.classOfDevice == 0x002504 || device.classOfDevice == 0x000508 else {
            log("Ignoring \(device.nameOrAddress!)")
            return
        }
        
        if device.isConnected() {
            log("Baseband connection already established")
        } else {
            log("Establishing baseband connection ...")
            
            let result = device.openConnection()
            
            guard result == kIOReturnSuccess else {
                log("Connection to \(device.addressString!) failed with IOReturn code \(result)")
                return
            }
            
            log("connection established")
        }
        
        let wiimote = Wiimote(device, number: wiimotes.count + 1)
        self.wiimotes.append(wiimote)
    }

    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
        log("Done searching for wiimotes")
    }
    
    func cleanup() {
        stopSearch()
        
        for wiimote in self.wiimotes {
            wiimote.cleanup()
        }
    }
}
