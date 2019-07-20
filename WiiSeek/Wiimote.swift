//
//  Wiimote.swift
//  WiiSeek
//
//  Created by Kyle King on 6/22/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import IOKit.hid
import Foundation

class Wiimote {
    var number: UInt8
    var device: IOHIDDevice
    
    public var description: String { return "Wiimote \(number)" }
    
    init(_ device: IOHIDDevice, number: Int) {
        self.device = device
        self.number = UInt8(number)
        
        // this sequence configures our speaker for 2kHz Yamaha ADPCM
        send(.muteSpeaker)
        send(.enableSpeaker)
        send(.writeMemory(0x04A20009, [0x01]))
        send(.writeMemory(0x04A20001, [0x08]))
        send(.configureSpeaker())
        send(.writeMemory(0x04A20008, [0x01]))
        send(.unmuteSpeaker)
        
        rumble()
        subscribe(.beep)   { _ in self.beep()   }
        subscribe(.rumble) { _ in self.rumble() }
    }

    deinit {
        print("Deallocating \(self)")
        IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func beep(duration: Double = 1) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) {_ in
            self.send(.play(Array(repeating: [0xC3,0x3C], count: 10).flatMap{$0}))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            timer.invalidate()
        }
    }
    
    func rumble(duration: Double = 0.5) {
        self.send(.ledOn(self.number, rumble: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.send(.ledOn(self.number, rumble: false))
        }
    }

    func send(bytes: [UInt8]) {
        var report = String()
        
        for byte in bytes {
            report.append(contentsOf: String(format: "%02hhx ", byte))
        }
        
        //log("\(self): sending [\(report)]")
        
        let ioreturn = IOHIDDeviceSetReport(
            device,
            kIOHIDReportTypeOutput,
            CFIndex(bytes[0]),
            bytes,
            bytes.count
        );
        
        if ioreturn != kIOReturnSuccess {
            print("\(self): send error (IOReturn \(ioreturn & 0x3fff))")
        }
    }
    
    func send(_ command: Command) {
        self.send(bytes: command.bytes)
    }
}
