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
    private(set) var peripheralDelegate: CBLockerPeripheralService?

    init(type: CBLockerActionType, token: String, locker: CBLockerModel, isRetry: Bool, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        super.init()

        NSLog(" CBLockerPeripheralMaintenanceService init")

        self.token = token

        peripheralDelegate = CBLockerPeripheralService(type: type, locker: locker, delegate: self, isRetry: isRetry, success: success, failure: failure)
    }
}

extension CBLockerPeripheralMaintenanceService: CBLockerPeripheralDelegate {
    func getKey(locker: CBLockerModel, success: @escaping (Data) -> Void, failure: @escaping (SPRError) -> Void) {
        NSLog(" CBLockerPeripheralMaintenanceService getKey \(locker.id) \(locker.readData)")

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

    func saveKey(locker: CBLockerModel, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        NSLog(" CBLockerPeripheralTakeService saveKey \(locker.id) \(locker.readData)")

        let reqData = MaintenanceKeyGetResultReqData(spacerId: locker.id, readData: locker.readData)

        API.post(
            path: ApiPaths.MaintenanceKeyGetResult,
            token: token,
            reqData: reqData,
            success: { (_: MaintenanceKeyGetResultResData) in
                success()
            },
            failure: failure)
    }
}
