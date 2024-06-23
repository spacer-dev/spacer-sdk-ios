//
//  CBLockerPeripheralTakeService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

class CBLockerPeripheralTakeService: NSObject {
    private var token = String()
    private(set) var peripheralDelegate: CBLockerPeripheralService?

    init(type: CBLockerActionType, token: String, locker: CBLockerModel, isRetry: Bool, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()
        self.token = token
        peripheralDelegate = CBLockerPeripheralService(type: type, locker: locker, delegate: self, isRetry: isRetry, success: success, failure: failure)
    }
}

extension CBLockerPeripheralTakeService: CBLockerPeripheralDelegate {
    func getKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = KeyGetReqData(spacerId: locker.id)
        print("BLE通信:鍵取得API")

        API.post(
            path: ApiPaths.KeyGet,
            token: token,
            reqData: reqData,
            success: { (resData: KeyGetResData) in
                if let key = resData.key {
                    if let data = "\(CBLockerConst.TakeKeyPrefix), \(key)".data(using: String.Encoding.utf8, allowLossyConversion: true) {
                        return success(data)
                    }
                }
                failure(SPRError.ApiFailed)
            },
            failure: failure)
    }

    func saveKey(locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = KeyGetResultReqData(spacerId: locker.id)
        print("BLE通信:解錠API")

        API.post(
            path: ApiPaths.KeyGetResult,
            token: token,
            reqData: reqData,
            success: { (_: KeyGetResultResData) in
                success()
            },
            failure: failure)
    }
}
