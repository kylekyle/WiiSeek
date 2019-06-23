//
//  AppDelegate.swift
//  WiiSeek
//
//  Created by Kyle King on 6/16/19.
//  Copyright © 2019 Kyle King. All rights reserved.
//
/*
import Cocoa
import IOBluetooth

@NSApplicationMain
class AppDelegateBackup: NSObject, NSApplicationDelegate, IOBluetoothDeviceAsyncCallbacks {
    
    var control: IOBluetoothL2CAPChannel?
    var interrupt: IOBluetoothL2CAPChannel?
    
    func updateStatus(message: String) {
        NotificationCenter.default.post(
            Notification.init(
                name: Notification.Name.statusUpdate, object: message
            )
        )
    }
    
    func remoteNameRequestComplete(_ device: IOBluetoothDevice!, status: IOReturn) {
        updateStatus(message: "remoteNameRequestComplete!")
    }
    
    func connectionComplete(_ device: IOBluetoothDevice!, status: IOReturn) {
        updateStatus(message: "connectionComplete!")
    }
    
    func sdpQueryComplete(_ device: IOBluetoothDevice!, status: IOReturn) {
        updateStatus(message: "SDP query complete!")
        
        
        // Open Channels for Incoming Connections
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else {
            updateStatus(message: "Could not read paired devices!")
            return
        }
        
        let connected = devices.filter { $0.isConnected() }
        
        for device in connected {
            print(device.name!)
            //print(device.performSDPQuery(self))
            
            guard IOBluetoothL2CAPChannel
                .register(forChannelOpenNotifications: self,
                          selector: #selector(newL2CAPChannelOpened),
                          withPSM: BluetoothL2CAPPSM(kBluetoothL2CAPPSMHIDControl),
                          direction: kIOBluetoothUserNotificationChannelDirectionIncoming) != nil else
            {
                print("failed to register control channel")
                return
            }
            
            let ret = device.openL2CAPChannelAsync(&interrupt, withPSM: BluetoothL2CAPPSM(0x11), delegate: self)
            if ret != kIOReturnSuccess {
                updateStatus(message: "data open failed: \(ret)")
            } else {
                updateStatus(message: "data open succeeded")
            }
            
            var bytes: [UInt8] = [0x52, 0x11, 0x01]
            let error = interrupt?.writeAsync(&bytes, length: UInt16(bytes.count), refcon: nil)
            
            if error != kIOReturnSuccess {
                updateStatus(message: "Write failed: \(String(describing: error))")
            }
        }
    }
    
    @objc func l2capChannelData(channel: IOBluetoothL2CAPChannel!, data dataPointer: UnsafeMutableRawPointer, length dataLength: Int) {
        updateStatus(message: "l2capChannelData!?!?")
    }
    
    @objc func l2capChannelOpenComplete(channel: IOBluetoothL2CAPChannel!, status error: IOReturn) {
        updateStatus(message: "l2capChannelOpenComplete!?!?")
    }
    
    @objc func l2capChannelClosed(channel: IOBluetoothL2CAPChannel!) {
        updateStatus(message: "l2capChannelClosed!?!?")
    }
    
    @objc func l2capChannelWriteComplete(channel: IOBluetoothL2CAPChannel!, refcon: UnsafeMutableRawPointer, status error: IOReturn) {
        updateStatus(message: "l2capChannelWriteComplete!?!?")
    }
    
    @objc func newL2CAPChannelOpened(notification: IOBluetoothUserNotification, channel: IOBluetoothL2CAPChannel) {
        //channel.setDelegate(self)
        updateStatus(message: "newL2CAPChannelOpened!?!?")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        control?.close()
        interrupt?.close()
    }
}

*/
