//
//  SPRError.swift
//
//
//  Created by Takehito Soi on 2021/06/22.
//

import Foundation

//  [変更前]
public struct SPRError {
//  [変更後]
//public struct SPRError: Equatable {
    public var code: String
    public var message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }

    /// API (E21002001 〜 E21002100)
    static let ApiFailed = SPRError(code: "E21002001", message: "api request failed")
    static let ApiDecodingFailed = SPRError(code: "E21002002", message: "failed to decode api response data")

    /// CB  Central  (E21010001 〜 E21011000)
    static let CBPoweredOff = SPRError(code: "E21010001", message: "bluetooth is powered off")
    static let CBResetting = SPRError(code: "E21010002", message: "bluetooth is resetting")
    static let CBUnauthorized = SPRError(code: "E21010003", message: "bluetooth is unauthorized")
    static let CBUnknown = SPRError(code: "E21010004", message: "bluetooth is unknown")
    static let CBUnsupported = SPRError(code: "E21010005", message: "bluetooth is unsupported")

    static let CBCentralTimeout = SPRError(code: "E21010101", message: "central scanning timed out")
    static let CBConnectingFailed = SPRError(code: "E21010102", message: "central connecting failed")

    /// CB  Peripheral(E21011001 〜 E21012000)
    static let CBServiceNotFound = SPRError(code: "E21011001", message: "peripheral service is not found")
    static let CBCharacteristicNotFound = SPRError(code: "E21011002", message: "peripheral characteristic is not found")
    static let CBReadingCharacteristicFailed = SPRError(code: "E21011003", message: "peripheral reading characteristic failed")
    static let CBWritingCharacteristicFailed = SPRError(code: "E21011004", message: "peripheral writing characteristic failed")

    static let CBPeripheralNotFound = SPRError(code: "E21011101", message: "peripheral is not found")

    static let CBConnectStartTimeout = SPRError(code: "E21011201", message: "timeout occurred while connecting to peripheral")
    static let CBConnectDiscoverTimeout = SPRError(code: "E21011202", message: "timeout occurred while discovering characteristic")
    static let CBConnectReadTimeoutBeforeWrite = SPRError(code: "E21011203", message: "timeout occurred while reading the value of the characteristic before write")
    static let CBConnectReadTimeoutAfterWrite = SPRError(code: "E21011204", message: "timeout occurred while reading the value of the characteristic after write")
    static let CBConnectWriteTimeout = SPRError(code: "E21011205", message: "timeout occurred while writing value to characteristic")
    static let CBConnectDuringTimeout = SPRError(code: "E21011206", message: "timeout occurred during connection processing")
}
