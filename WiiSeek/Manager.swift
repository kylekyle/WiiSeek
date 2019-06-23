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
            log("Could not initiate bluetooth search")
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
        log("Discovered \(device.addressString!)")
        
        // validate wiimote is actually a wiimote
        if !device.isConnected() {
            let result = device.openConnection()
            guard result == kIOReturnSuccess else {
                log("Connection to \(device.addressString!) failed with IOReturn code \(result)")
                return
            }
        }
        
        let wiimote = Wiimote(device, player: wiimotes.count + 1)
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
