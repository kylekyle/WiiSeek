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
    var name: String
    var number: UInt8
    var data: Channel
    var control: Channel
    var device: IOBluetoothDevice
    
    init(_ device: IOBluetoothDevice, number: Int) {
        self.device = device
        self.number = UInt8(number)
        self.name = "Wiimote \(number)"
        
        self.control = Channel(
            device: self.device,
            name: "\(self.name) (control)",
            psm: BluetoothL2CAPPSM(kBluetoothL2CAPPSMHIDControl)
        )
        
        self.data = Channel(
            device: self.device,
            name: "\(self.name) (data)",
            psm: BluetoothL2CAPPSM(kBluetoothL2CAPPSMHIDInterrupt)
        )
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {timer in
            if self.data.ready && self.control.ready {
                timer.invalidate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.send(.muteSpeaker)
                    self.send(.enableSpeaker)
                    self.send(.writeMemory(0x04A20009, [0x01]))
                    self.send(.writeMemory(0x04A20001, [0x08]))
                    self.send(.writeMemory(0x04a20001, [0x00, 0x40, 0x70, 0x17, 0x60, 0x00, 0x00]))
                    self.send(.writeMemory(0x04A20008, [0x01]))
                    self.send(.unmuteSpeaker)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.play()
                    }
                }
            }
        }
    }
    
    @objc func play() {
        log("PLAYING")
        let sourceURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let audio = sourceURL.appendingPathComponent("Audio.au")
        log(audio.absoluteString)
        
        guard let data = NSData(contentsOf: audio) else {
            log("could not load audio!")
            return
        }
        
        var start = 0
        var buffer = [UInt8](repeating: 0x00, count: data.length)
        data.getBytes(&buffer, length: data.length)
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {timer in
            let stop = min(start + 20, buffer.count)
            self.send(.play(Array(buffer[start..<stop])))
            
            if stop >= buffer.count {
                timer.invalidate()
            } else {
                start = stop
            }
        }
    }
    
    func blink() {
        log("blink")
    }
    
    func rumble(duration: Double = 0.5) {
        self.send(.ledOn(self.number, rumble: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.send(.ledOn(self.number, rumble: false))
        }
    }
    
    func send(_ command: Command) {
        self.data.send(command.bytes)
    }
    
    func cleanup() {
        self.control.close()
        self.data.close()
        self.device.closeConnection()
        log("\(self.name): disconnected")
    }
}
