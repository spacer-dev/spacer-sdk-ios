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

    init(token: String, locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()

        NSLog(" CBLockerPeripheralTakeService init")
        
        self.token = token

        peripheralDelegate = CBLockerPeripheralService(locker: locker, delegate: self, skipFirstRead: true, success: success, failure: failure)
    }
}

extension CBLockerPeripheralTakeService: CBLockerPeripheralDelegate {
    func getKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
        NSLog(" CBLockerPeripheralTakeService getKey \(locker.id) \(locker.readData)")
        
        let reqData = KeyGetReqData(spacerId: locker.id)

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
        NSLog(" CBLockerPeripheralTakeService saveKey \(locker.id) \(locker.readData)")
        
        let reqData = KeyGetResultReqData(spacerId: locker.id, readData: locker.readData)

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
