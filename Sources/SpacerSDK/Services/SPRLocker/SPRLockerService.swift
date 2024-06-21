//
//  Provides basic locker information
//
//
//  Created by Takehito Soi on 2021/07/13.
//

import Foundation

public class SPRLockerService {
    /// Get multiple locker basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerIds: Locker IDs, ex) ["SPACER054", "SPACER055"]
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func get(token: String, spacerIds: [String], success: @escaping ([SPRLockerModel]) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = SPRLockersGetReqData(spacerIds: spacerIds)

        API.post(
            path: ApiPaths.lockerSpacerGet,
            token: token,
            reqData: reqData,
            success: { (response: SPRLockersGetResData) in
                guard let spacersResData = response.spacers else { return failure(SPRError.ApiFailed) }
                let spacers = spacersResData.map { $0.toModel() }.sorted(by: { $0.id < $1.id })
                success(spacers)
            },
            failure: failure)
    }
    
    /// Get multiple locker unit basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker Unit IDs, ex) "SPACER054"
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func getLocker(token: String, spacerId: String, success: @escaping (SPRLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = SPRLockerGetReqData(spacerId: spacerId)
        let path = "\(ApiPaths.lockerSpacer)\(spacerId)"
        
        API.get(
            path: path,
            token: token,
            reqData: reqData,
            success: { (response: SPRLockerGetResData) in
                guard let spacer = response.spacer?.toModel() else { return failure(SPRError.ApiFailed) }
//                let spacer = spacersResData.toModel()
                success(spacer)
            },
            failure: failure)
    }

    /// Get multiple locker unit basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - unitIds: Locker Unit IDs, ex) ["05", "06"]
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func get(token: String, unitIds: [String], success: @escaping ([SPRLockerUnitModel]) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = SPRLockerUnitGetReqData(unitIds: unitIds)

        API.post(
            path: ApiPaths.lockerUnitGet,
            token: token,
            reqData: reqData,
            success: { (response: SPRLockerUnitGetResData) in
                guard let unitsResData = response.units else { return failure(SPRError.ApiFailed) }
                let units = unitsResData.map { $0.toModel() }.sorted(by: { $0.id < $1.id })
                success(units)
            },
            failure: failure)
    }
}
