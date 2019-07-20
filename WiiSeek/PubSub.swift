//
//  PubSub.swift
//  WiiSeek
//
//  Created by Kyle King on 6/21/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//

import Foundation

enum Topic {
    case beep
    case rumble
}

func publish(_ topic: Topic, _ object: Any? = nil) {
    NotificationCenter.default.post(
        Notification.init(
            name: Notification.Name(String(describing: topic)),
            object: object
        )
    )
}

func subscribe(_ topic: Topic, _ callback: @escaping (Any?) -> Void) {
    NotificationCenter.default.addObserver(
        forName: Notification.Name(String(describing: topic)),
        object: nil,
        queue: OperationQueue.main) {(notification) in
            callback(notification.object)
    }
}
