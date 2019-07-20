//
//  ViewController.swift
//  WiiSeek
//
//  Created by Kyle King on 6/16/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBAction func beepButton(_ sender: Any) {
        print("beep")
        publish(.beep)
    }
    
    @IBAction func rumbleButton(_ sender: Any) {
        print("beep")
        publish(.rumble)
    }
}
