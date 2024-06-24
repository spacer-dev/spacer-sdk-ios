//
//  File.swift
//  
//
//  Created by ASW on 2024/06/20.
//

import Foundation

public class HttpLockerService {
    /// Get multiple locker basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker IDs, ex)  "SPACER054"
    ///   - lat: User current location latitude, ex)  "12.099406802793892"
    ///   - lng: User current location longitude, ex)  "209.004948393847015"
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func put(token: String, spacerId: String, lat:Double, lng:Double, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = HttpLockerReqData(spacerId: spacerId, lat: lat, lng: lng)

        API.post(
            path: ApiPaths.LocationRPiBoxPut,
            token: token,
            reqData: reqData,
            success: { (response: HttpLockerResData) in success()},
            failure: failure)
    }
        
    /// Get multiple locker unit basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker Unit IDs, ex) "SPACER054"
    ///   - lat: User current location latitude, ex)  "12.099406802793892"
    ///   - lng: User current location longitude, ex)  "209.004948393847015"
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func take(token: String, spacerId: String, lat:Double, lng:Double, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = HttpLockerReqData(spacerId: spacerId, lat: lat, lng: lng)

        API.post(
            path: ApiPaths.LocationRPiBoxTake,
            token: token,
            reqData: reqData,
            success: { (response: HttpLockerResData) in success()},
            failure: failure)
    }

    /// Get multiple locker unit basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker Unit IDs, ex) "SPACER054"
    ///   - lat: User current location latitude, ex)  "12.099406802793892"
    ///   - lng: User current location longitude, ex)  "209.004948393847015"
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func openForMaintenance(token: String, spacerId: String, lat:Double, lng:Double, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = HttpLockerReqData(spacerId: spacerId, lat: lat, lng: lng)

        API.post(
            path: ApiPaths.LocationRPiBoxOpenForMaintenance,
            token: token,
            reqData: reqData,
            success: { (response: HttpLockerResData) in success()},
            failure: failure)
    }}
