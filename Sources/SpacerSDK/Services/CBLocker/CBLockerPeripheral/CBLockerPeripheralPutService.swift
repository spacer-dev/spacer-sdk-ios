//
//  CBLockerPeripheralPutService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
import Foundation

class CBLockerPeripheralPutService: NSObject {
    private var token = String()
    private(set) var peripheralDelegate: CBLockerPeripheralService?

    init(type: CBLockerActionType, token: String, locker: CBLockerModel, isRetry: Bool, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()
        self.token = token

        peripheralDelegate = CBLockerPeripheralService(type: type, locker: locker, delegate: self, isRetry: isRetry, success: success, failure: failure)
    }
}

extension CBLockerPeripheralPutService: CBLockerPeripheralDelegate {
    func getKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = KeyGenerateReqData(spacerId: locker.id, readData: locker.readData)
        
        API.post(
            path: ApiPaths.KeyGenerate,
            token: token,
            reqData: reqData,
            success: { (resData: KeyGenerateResData) in
                if let key = resData.key {
                    if let data = "\(CBLockerConst.PutKeyPrefix), \(key)".data(using: String.Encoding.utf8, allowLossyConversion: true) {
                        return success(data)
                    }
                }
                failure(SPRError.ApiFailed)
            },
            failure: failure)
    }

    func saveKey(locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = KeyGenerateResultReqData(spacerId: locker.id)

        API.post(
            path: ApiPaths.KeyGenerateResult,
            token: token,
            reqData: reqData,
            success: { (_: KeyGenerateResultResData) in
                success()
            },
            failure: failure)
    }
}
