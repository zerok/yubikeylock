//
//  main.swift
//  yubikeylock
//
//  Created by Horst Gutmann on 14.01.18.
//  Copyright © 2018 Horst Gutmann. All rights reserved.
//
import Foundation
import AppKit
import IOKit
import IOKit.usb

let disconnectedNotification = Notification(name: Notification.Name("yubikeyDisconnected"))
let connectedNotification = Notification(name: Notification.Name("yubikeyConnected"))

class SleepObserver {
    var previouslyPresent: Bool
    var isLocked: Bool
    var lock: NSLock
    
    init() {
        self.previouslyPresent = false
        self.isLocked = false
        self.lock = NSLock()
    }
    
    @objc
    func onScreenLocked() {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.isLocked = true
    }
    
    @objc
    func onScreenUnlocked() {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.isLocked = false
    }
    
    @objc
    func onDisconnect(notification: Notification) {
        self.lock.lock()
        defer { self.lock.unlock() }
        if !this.isLocked {
            NSWorkspace.shared.launchApplication("ScreenSaverEngine.app")
        }
    }
    
    func check() {
        let present = self.isYubikeyPresent()
        if self.previouslyPresent && !present {
            NotificationCenter.default.post(disconnectedNotification)
        }
        if !self.previouslyPresent && present {
            NotificationCenter.default.post(connectedNotification)
        }
        self.lock.lock()
        defer { self.lock.unlock() }
        self.previouslyPresent = present
    }
    
    func isYubikeyPresent() -> Bool {
        var portIterator: io_iterator_t = 0
        defer {
            IOObjectRelease(portIterator)
        }
        let matching = IOServiceMatching(kIOUSBDeviceClassName)
        IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &portIterator)
        while true {
            let device = IOIteratorNext(portIterator)
            if device == 0 {
                break
            }
            let deviceName = getDeviceName(device)
            if deviceName.hasPrefix("Yubikey") {
                return true
            }
        };
        return false
    }
}

func getDeviceName(_ device: io_iterator_t) -> String {
    var deviceNamePtr = UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
    defer {deviceNamePtr.deallocate(capacity: MemoryLayout<io_name_t>.size)}
    IORegistryEntryGetName(device, deviceNamePtr);
    return String(cString: deviceNamePtr)
}

let this = SleepObserver()

DistributedNotificationCenter.default().addObserver(this, selector: #selector(SleepObserver.onScreenLocked), name: Notification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
DistributedNotificationCenter.default().addObserver(this, selector: #selector(SleepObserver.onScreenUnlocked), name: Notification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
NotificationCenter.default.addObserver(this, selector: #selector(SleepObserver.onDisconnect(notification:)), name: disconnectedNotification.name, object: nil)

DispatchQueue.global().async {
    while true {
        this.check()
        Thread.sleep(forTimeInterval: 2)
    }
    
}
RunLoop.current.run()
