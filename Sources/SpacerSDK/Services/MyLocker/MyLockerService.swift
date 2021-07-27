//
//  Provides operation of the locker you are using
//
//
//  Created by Takehito Soi on 2021/07/09.
//

import Foundation

public class MyLockerService {
    /// Get a list of your lockers in use
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func get(token: String, success: @escaping ([MyLockerModel]) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = MyLockerGetReqData()

        API.post(
            path: ApiPaths.myLockerGet,
            token: token,
            reqData: reqData,
            success: { (response: MyLockerGetResData) in
                let myLockers = response.myLockers?.map { $0.toModel() } ?? []
                success(myLockers)
            },
            failure: failure)
    }

    /// Reserve available locker
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func reserve(token: String, spacerId: String, success: @escaping (MyLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = MyLockerReserveReqData(spacerId: spacerId)

        API.post(
            path: ApiPaths.myLockerReserve,
            token: token,
            reqData: reqData,
            success: { (response: MyLockerReserveResData) in
                guard let myLocker = response.myLocker?.toModel() else { return failure(SPRError.ApiFailed) }
                success(myLocker)
            },
            failure: failure)
    }

    /// Cancel the locker you reserved
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func reserveCancel(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = MyLockerReserveCancelReqData(spacerId: spacerId)

        API.post(
            path: ApiPaths.myLockerReserveCancel,
            token: token,
            reqData: reqData,
            success: { (_: MyLockerReserveCancelResData) in
                success()
            },
            failure: failure)
    }

    /// Share the locker with yourself using the url key
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - urlKey: Shared url key
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func shared(token: String, urlKey: String, success: @escaping (MyLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = MyLockerSharedReqData(urlKey: urlKey)

        API.post(
            path: ApiPaths.myLockerShared,
            token: token,
            reqData: reqData,
            success: { (response: MyLockerSharedResData) in
                guard let myLocker = response.myLocker?.toModel() else { return failure(SPRError.ApiFailed) }
                success(myLocker)
            },
            failure: failure)
    }
}
