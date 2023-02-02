//
//  Provides discovery, connection and read / write operations for BLE devices
//
//
//  Created by Takehito Soi on 2021/06/22.
//

import CoreBluetooth
import Foundation

public class CBLockerService: NSObject
{
    /// Discover peripheral devices
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func scan(
        token: String, success: @escaping ([SPRLockerModel]) -> Void, failure: @escaping (SPRError) -> Void)
    {
        CBLockerCentralScanService().scan(token: token, success: success, failure: failure)
    }

    /// Connect to a peripheral device. To put luggage in the locker
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func put(
        token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        CBLockerCentralConnectService().put(token: token, spacerId: spacerId, success: success, failure: failure)
    }

    /// Connect to a peripheral device. To take luggage from your locker
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func take(
        token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        CBLockerCentralConnectService().take(token: token, spacerId: spacerId, success: success, failure: failure)
    }
    
    /// Connect to a peripheral device. To open luggage from your maintenance locker
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func openForMaintenance(
        token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        CBLockerCentralConnectService().openForMaintenance(token: token, spacerId: spacerId, success: success, failure: failure)
    }

    /// Connect to take luggage from locker with shared key
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - urlKey: Shared url key
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func take(
        token: String, urlKey: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        MyLockerService().shareUrlKey(
            token: token,
            urlKey: urlKey,
            success: { myLocker in
                self.take(token: token, spacerId: myLocker.id, success: success, failure: failure)
            },
            failure: failure)
    }
}
