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
        
        self.rumble()
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {timer in
//           // if self.data.ready {//&& self.control.ready {
//                timer.invalidate()

//                self.send(.muteSpeaker)
//                self.send(.enableSpeaker)
//                self.send(.writeMemory(0x04A20009, [0x01]))
//                self.send(.writeMemory(0x04A20001, [0x08]))
//                self.send(.configureSpeaker())
//                self.send(.writeMemory(0x04A20008, [0x01]))
//                self.send(.unmuteSpeaker)
//
//                self.play()
            //}
//        }
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
        
//        var start = 0
//        var buffer: [UInt8] = []
//
//        for byte in stride(from: 0x33, to: 0xAA, by: 0x01) {
//            buffer.append(contentsOf: [UInt8](repeating: UInt8(byte), count: 100))
//        }
        var buffer = [UInt8](repeating: 0x00, count: data.length)
        data.getBytes(&buffer, length: data.length)
//        for start in stride(from: 92, to: buffer.count, by: 20) {
//            let begin = DispatchTime.now()
//            let stop = min(start + 20, buffer.count)
//            log("start=\(start) stop=\(stop) buffer.count=\(buffer.count)")
//            self.send(.play(Array(buffer[start..<stop])))
//            let end = DispatchTime.now()
//            let delay = end.uptimeNanoseconds-begin.uptimeNanoseconds
//            print(10000 - delay*1000000)
//            usleep(UInt32(min(0, useconds_t(10000 - delay*1000000))))
//        }
//        var start = 92
//        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {timer in
//            let stop = min(start + 20, buffer.count)
//            self.send(.play(Array(buffer[start..<stop])))
//
//            if stop >= buffer.count {
//                timer.invalidate()
//            } else {
//                start = stop
//            }
//        }
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
        
        log("\(self): sending [\(report)]")
        
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
