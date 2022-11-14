//
//  CBLockerPeripheralMaintenanceService.swift
//  
//
//  Created by s.norimatsu on 2022/10/24.
//
import CoreBluetooth
import Foundation

class CBLockerPeripheralMaintenanceService: NSObject {
    private var token = String()
    private var success: () -> Void = {}
    private var failure: (SPRError) -> Void = { _ in }
    private(set) var connectService: CBLockerPeripheralService?

    init(token: String, locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()

        self.token = token
        self.success = success
        self.failure = failure
        connectService = CBLockerPeripheralService(locker: locker, delegate: self, skipFirstRead: true)
    }
}

extension CBLockerPeripheralMaintenanceService: CBLockerPeripheralDelegate {
    func onGetKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = MaintenanceKeyGetReqData(spacerId: locker.id)

        API.post(
            path: ApiPaths.MaintenanceKeyGet,
            token: token,
            reqData: reqData,
            success: { (resData: MaintenanceKeyGetResData) in
                if let encryptedData = resData.encryptedData {
                    if let data = "\(encryptedData)".data(using: String.Encoding.utf8, allowLossyConversion: true) {
                        return success(data)
                    }
                }
                failure(SPRError.ApiFailed)
            },
            failure: failure)
    }

    func onSuccess(locker: CBLockerModel) {
        let reqData = MaintenanceKeyGetResultReqData(spacerId: locker.id, readData: locker.readData)

        API.post(
            path: ApiPaths.MaintenanceKeyGetResult,
            token: token,
            reqData: reqData,
            success: { (_: MaintenanceKeyGetResultResData) in
                self.success()
            },
            failure: failure)
    }

    func onFailure(_ error: SPRError) {
        failure(error)
    }
}
