//
//  SPRError.swift
//
//
//  Created by Takehito Soi on 2021/06/22.
//

import Foundation

public struct SPRError {
    public var code: String
    public var message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }

    /// API (E21002001 〜 E21002100)
    static let ApiFailed = SPRError(code: "E21002001", message: "api request failed")
    static let ApiDecodingFailed = SPRError(code: "E21002002", message: "api response decoding failed")
    static let ApiResDataFailed = SPRError(code: "E21002001", message: "api response data failed")

    /// CB  Central  (E21010001 〜 E21011000)
    static let CBPoweredOff = SPRError(code: "E21010001", message: "bluetooth is powered off")
    static let CBResetting = SPRError(code: "E21010002", message: "bluetooth is resetting")
    static let CBUnauthorized = SPRError(code: "E21010003", message: "bluetooth is unauthorized")
    static let CBUnknown = SPRError(code: "E21010004", message: "bluetooth is unknown")
    static let CBUnsupported = SPRError(code: "E21010005", message: "bluetooth is unsupported")

    static let CBCentralTimeout = SPRError(code: "E21010101", message: "central timed out")
    static let CBConnectingFailed = SPRError(code: "E21010102", message: "central connecting failed")

    /// CB  Peripheral(E21011001 〜 E21012000)
    static let CBDiscoveringServicesFailed = SPRError(code: "E21011001", message: "peripheral discovering services failed")
    static let CBDiscoveringCharacteristicsFailed = SPRError(code: "E21011002", message: "peripheral discovering characteristics failed")
    static let CBReadingCharacteristicFailed = SPRError(code: "E21011003", message: "peripheral reading characteristic failed")
    static let CBWritingCharacteristicFailed = SPRError(code: "E21011004", message: "peripheral writing characteristic failed")

    static let CBPeripheralNotFound = SPRError(code: "E21011101", message: "peripheral is not found")
}
