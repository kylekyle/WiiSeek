//
//  Wiimote.swift
//  WiiSeek
//
//  Created by Kyle King on 6/22/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Foundation
import IOBluetooth

class Wiimote {
    var address: String
    var control: Channel
    var interrupt: Channel
    var device: IOBluetoothDevice
    var playerMask: UInt8 = 0b0001_0000
    
    enum CommandType {
        case rumbleOn
        case rumbleOff
        case ledOn
        case ledOff
    }
    
    let Commands: [CommandType: [UInt8]] = [
        .ledOn:     [0xa2, 0x11, 0x00],
        .ledOff:    [0xa2, 0x11, 0x00],
        .rumbleOn:  [0xa2, 0x11, 0x01],
        .rumbleOff: [0xa2, 0x11, 0x00]
    ]
    
    class Channel: IOBluetoothL2CAPChannelDelegate {
        var address: String
        var psm: BluetoothL2CAPPSM
        var channel: IOBluetoothL2CAPChannel?
        var queue: DispatchQueue
        
        init(_ psm: Int, address: String) {
            self.address = address
            self.psm = BluetoothL2CAPPSM(psm)
            self.queue = DispatchQueue(label: address)
        }
        
        func l2capChannelOpenComplete(_ c: IOBluetoothL2CAPChannel!, status error: IOReturn) {
            log("\(self.psm) channel opened on \(self.address)")
        }
        
        func l2capChannelData(_ l2capChannel: IOBluetoothL2CAPChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
            log("Recieved data from \(self.address) on \(self.psm) channel")
        }
        
        func close() {
            channel?.close()
        }
    }
    
    init(_ device: IOBluetoothDevice, player: Int) {
        self.device = device
        self.address = device.addressString!
        self.control = Channel(kBluetoothL2CAPPSMHIDControl, address: self.address)
        self.interrupt = Channel(kBluetoothL2CAPPSMHIDInterrupt, address: self.address)
        
        for _ in (1..<player) {
            playerMask = (playerMask << 1) | playerMask
        }
        
        let cResult = device.openL2CAPChannelSync(&control.channel, withPSM: control.psm, delegate: control)
        
        guard cResult == kIOReturnSuccess else {
            log("Failed to open control channel to \(self.address) (\(cResult))")
            return
        }
        
        let iResult = device.openL2CAPChannelSync(&interrupt.channel, withPSM: interrupt.psm, delegate: interrupt)

        guard iResult == kIOReturnSuccess else {
            log("Failed to open interrupt channel to \(self.address) (\(iResult))")
            return
        }
        
        rumble()
    }
    
    func rumble() {
        self.send(.rumbleOn)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.send(.rumbleOff)
        }
    }
    
    func send(_ type: CommandType) {
        guard let channel = interrupt.channel else {
            log("Cannot send command to \(self.address): No channels open!")
            return
        }
        
        var bytes = Commands[type]!
        
        // mask in the player LED
        if type != .ledOff {
            bytes[bytes.count-1] = bytes[bytes.count-1] | playerMask
        }
        
        let error = channel.writeSync(&bytes, length: UInt16(bytes.count))
        
        if error != kIOReturnSuccess {
            log("Could not execute command \(type) on \(self.address): \(error)")
        }
    }
    
    func cleanup() {
        self.control.close()
        self.interrupt.close()
        self.device.closeConnection()
        log("Disconnected from \(self.address)")
    }
}
