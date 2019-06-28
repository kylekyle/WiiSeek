//
//  Channel.swift
//  WiiSeek
//
//  Created by Kyle King on 6/27/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import IOBluetooth

class Channel: IOBluetoothL2CAPChannelDelegate {
    var name: String
    var ready = false
    var psm: BluetoothL2CAPPSM
    var device: IOBluetoothDevice
    var channel: IOBluetoothL2CAPChannel?
    
    init(device: IOBluetoothDevice, name: String, psm: BluetoothL2CAPPSM) {
        self.psm = psm
        self.name = name
        self.device = device
        self.connect()
    }
    
    func connect() {
        let result = device.openL2CAPChannelSync(&self.channel, withPSM: psm, delegate: self)
        
        switch result {
        case kIOReturnSuccess:
            log("\(self.name): channel opened")
            return
        case kIOReturnNotOpen:
            log("\(self.name): error opening channel - device not open")
        default:
            log("\(self.name): error opening channel - received an unknown IOReturn (\(result))")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connect()
        }
    }
    
    func send(_ bytes: [UInt8]) {
        var buffer = bytes
        var report = String()
        
        guard ready else {
            log("\(self.name): error - send attempt on closed channel")
            return
        }
        
        for byte in bytes {
            report.append(contentsOf: String(format: "%02hhx ", byte))
        }
        
        log("\(self.name): sending [\(report)]")
        
        let error = channel!.writeSync(&buffer, length: UInt16(buffer.count))
        
        if error != kIOReturnSuccess {
            log("\(self.name): send error \(error)")
        }
    }
    
    func l2capChannelOpenComplete(_ c: IOBluetoothL2CAPChannel!, status error: IOReturn) {
        self.ready = true
        log("\(self.name): channel ready")
    }
    
    func l2capChannelData(_ l2capChannel: IOBluetoothL2CAPChannel!, data: UnsafeMutableRawPointer!, length: Int) {
        var report = String()
        
        for i in 0..<length {
            let byte = data.load(fromByteOffset: i, as: UInt8.self)
            report.append(contentsOf: String(format: "%02hhx ", byte))
        }
        
        log("\(self.name): received [\(report)]")
    }
    
    func close() {
        channel?.close()
    }
}
