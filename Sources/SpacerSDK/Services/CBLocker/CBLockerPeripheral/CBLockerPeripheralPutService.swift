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
    private var success: () -> Void = {}
    private var failure: (SPRError) -> Void = { _ in }
    private(set) var connectService: CBLockerPeripheralService?

    init(token: String, locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()

        self.token = token
        self.success = success
        self.failure = failure
        connectService = CBLockerPeripheralService(locker: locker, delegate: self)
    }
}

extension CBLockerPeripheralPutService: CBLockerPeripheralDelegate {
    func onGetKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
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
                failure(SPRError.ApiResDataFailed)
            },
            failure: failure)
    }

    func onSuccess(locker: CBLockerModel) {
        let reqData = KeyGenerateResultReqData(spacerId: locker.id, readData: locker.readData)

        API.post(
            path: ApiPaths.KeyGenerateResult,
            token: token,
            reqData: reqData,
            success: { (_: KeyGenerateResultResData) in
                self.success()
            },
            failure: failure)
    }

    func onFailure(_ error: SPRError) {
        failure(error)
    }
}
