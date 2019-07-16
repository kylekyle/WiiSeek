//
//  Command.swift
//  WiiSeek
//
//  Created by Kyle King on 6/27/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

struct Command {
    let bytes: [UInt8]
    
    static func ledOn(_ led: UInt8, rumble: Bool = false) -> Command {
        return Command(bytes: [0x11, (8 << led) | (rumble ? 1 : 0)])
    }
    
    static func ledOff(rumble: Bool = false) -> Command {
        return Command(bytes: [0x11, (rumble ? 1 : 0)])
    }
    
    // do not write more than 16 bytes
    static func writeMemory(_ address: UInt32, _ data: [UInt8]) -> Command {
        var buffer = [
            0x16,
            UInt8((address >> 24) & 0xff),
            UInt8((address >> 16) & 0xff),
            UInt8((address >> 8) & 0xff),
            UInt8(address & 0xff),
            UInt8(data.count)
        ]
        
        buffer.append(contentsOf: data)
        buffer.append(contentsOf: Array(repeating: 0, count: 16-data.count))
        
        return Command(bytes: buffer)
    }
    
    // Do not send more than 20 bytes at a time
    static func play(_ data: [UInt8]) -> Command {
        var buffer: [UInt8] = [0x18, (UInt8(data.count << 3))]
        
        buffer.append(contentsOf: data)
        
        if data.count < 20 {
            buffer.append(contentsOf: Array(repeating: 0, count: 20-data.count))
        }
        
        //  print(buffer)
        
        return Command(bytes: buffer)
    }
    
    static func configureSpeaker(rate hzRate: Int = 4000, volume: Double = 1) -> Command {
        let adpcm_yamaha: UInt8 = 0x00
        let rate = UInt16(6000000/hzRate)
        let encodedVolume = UInt8(0x40 * volume)
        print(rate)
        print(UInt8(rate & 0xFF))
        print(UInt8(rate >> 8))
        return writeMemory(0x04a20001,
                           [0x00,
                            adpcm_yamaha,
                            UInt8(rate & 0xFF),
                            UInt8(rate >> 8),
                            encodedVolume,
                            0x00,
                            0x00]
        )
    }
    
    static let muteSpeaker   = Command(bytes: [0x19, 0x04])
    static let unmuteSpeaker = Command(bytes: [0x19, 0x00])
    static let enableSpeaker = Command(bytes: [0x14, 0x04])
    static let statusReport  = Command(bytes: [0x15, 0x00])
}
