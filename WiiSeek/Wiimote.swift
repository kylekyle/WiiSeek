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
        
        send(.muteSpeaker)
        send(.enableSpeaker)
        send(.writeMemory(0x04A20009, [0x01]))
        send(.writeMemory(0x04A20001, [0x08]))
        send(.configureSpeaker())
        send(.writeMemory(0x04A20008, [0x01]))
        send(.unmuteSpeaker)
        print("speaker enabled")
        //rumble()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.play()
        }
    }

    deinit {
        print("Deallocating \(self)")
        IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    @objc func play() {
        log("PLAYING")
        let sourceURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let audio = sourceURL.appendingPathComponent("Scale.wav")
        log(audio.absoluteString)
        
        guard let data = NSData(contentsOf: audio) else {
            log("could not load audio!")
            return
        }
        
//        var buffer = [UInt8](repeating: 0x00, count: data.length)
//        data.getBytes(&buffer, length: data.length)
        
        // 1 in 3 runs or so, this produces static 
        var start = 0
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {timer in
            let stop = min(start + 20, data.count)
            self.send(.play(Array(data[start..<stop])))
            print(Array(data[start..<stop]))
            if stop >= data.count {
                timer.invalidate()
            } else {
                start = stop
            }
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
            log("\(self): send error (IOReturn \(ioreturn & 0x3fff))")
        }
    }
    
    func send(_ command: Command) {
        self.send(bytes: command.bytes)
    }
}
