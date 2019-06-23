//
//  ViewController.swift
//  WiiSeek
//
//  Created by Kyle King on 6/16/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Cocoa

// we'll use our own log function since os_log is not thread safe!?!?
func log(_ message: String) {
    publish(.log, message)
}

class ViewController: NSViewController {
    
    @IBAction func searchButton(_ sender: NSButton) {
        publish(.stopSearch)
    }
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribe(.log) {(message) in
            let string = (message as! String) + "\n"
            self.textView.textStorage?.append(NSAttributedString(
                string: string, attributes: [
                    NSAttributedString.Key.foregroundColor: NSColor.white,
                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16)
                ])
            )
        }
    }
}
