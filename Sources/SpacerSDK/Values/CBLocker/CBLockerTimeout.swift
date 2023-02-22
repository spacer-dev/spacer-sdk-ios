//
//  CBLockerTimeout.swift
//
//
//  Created by s.norimatsu on 2022/08/27.
//
import Foundation

class CBLockerTimeout {
    private var name: String
    private var seconds: Double
    private var error: SPRError
    private var executable: (SPRError) -> Void = { _ in }
    private var workItem: DispatchWorkItem?

    init(name: String, seconds: Double, error: SPRError, executable: @escaping (SPRError) -> Void) {
        self.name = name
        self.seconds = seconds
        self.error = error
        self.executable = executable
    }

    func set() {
        workItem = DispatchWorkItem {
            self.executable(self.error)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem!)
    }

    func clear() {
        workItem?.cancel()
    }
}

class CBLockerConnectTimeouts {
    let start: CBLockerTimeout!
    let discover: CBLockerTimeout!
    let readBeforeWrite: CBLockerTimeout!
    let readAfterWrite: CBLockerTimeout!
    let write: CBLockerTimeout!
    let during: CBLockerTimeout!

    init(executable: @escaping (SPRError) -> Void) {
        start = CBLockerTimeout(name: "start connecting", seconds: CBLockerConst.StartTimeoutSeconds, error: SPRError.CBConnectStartTimeout, executable: executable)
        discover = CBLockerTimeout(name: "discover characteristic", seconds: CBLockerConst.DiscoverTimeoutSeconds, error: SPRError.CBConnectDiscoverTimeout, executable: executable)
        readBeforeWrite = CBLockerTimeout(name: "read characteristic before write", seconds: CBLockerConst.ReadTimeoutSeconds, error: SPRError.CBConnectReadTimeoutBeforeWrite, executable: executable)
        readAfterWrite = CBLockerTimeout(name: "read characteristic after write", seconds: CBLockerConst.ReadTimeoutSeconds, error: SPRError.CBConnectReadTimeoutAfterWrite, executable: executable)
        write = CBLockerTimeout(name: "write to characteristic", seconds: CBLockerConst.WriteTimeoutSeconds, error: SPRError.CBConnectWriteTimeout, executable: executable)
        during = CBLockerTimeout(name: "during connection processing", seconds: CBLockerConst.DuringTimeoutSeconds, error: SPRError.CBConnectDuringTimeout, executable: executable)
    }

    func clearAll() {
        [start, discover, readBeforeWrite, readAfterWrite, write, during].forEach { timeout in timeout?.clear() }
    }
}
