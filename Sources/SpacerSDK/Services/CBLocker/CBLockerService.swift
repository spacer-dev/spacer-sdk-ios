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
    private lazy var myLockerService = MyLockerService()
    private lazy var centralScanService = CBLockerCentralScanService()
    private lazy var centralConnectService = CBLockerCentralConnectService()

    /// Discover peripheral devices
    /// - Parameters:
    ///   - scanSec: Scan time (seconds)
    ///   - token: User token created on the server
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func scan(
        scanSec: Double = CBLockerConst.ScanSec,
        token: String, success: @escaping ([SPRLockerModel]) -> Void, failure: @escaping (SPRError) -> Void)
    {
        centralScanService.scan(scanSec: scanSec, token: token, success: success, failure: failure)
    }

    /// Connect to a peripheral device. To put luggage in the locker
    /// - Parameters:
    ///   - scanSec: Scan time (seconds)
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func put(
        scanSec: Double = CBLockerConst.ScanSec,
        token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        centralConnectService.put(
            scanSec: scanSec, token: token, spacerId: spacerId, success: success, failure: failure)
    }

    /// Connect to a peripheral device. To take luggage from your locker
    /// - Parameters:
    ///   - scanSec: Scan time (seconds)
    ///   - token: User token created on the server
    ///   - spacerId: Locker ID. ex) SPACER055
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func take(
        scanSec: Double = CBLockerConst.ScanSec,
        token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        centralConnectService.take(
            scanSec: scanSec, token: token, spacerId: spacerId, success: success, failure: failure)
    }

    /// Connect to take luggage from locker with shared key
    /// - Parameters:
    ///   - scanSec: <#scanSec description#>
    ///   - token: User token created on the server
    ///   - urlKey: Shared url key
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func take(
        scanSec: Double = CBLockerConst.ScanSec,
        token: String, urlKey: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void)
    {
        myLockerService.shared(
            token: token,
            urlKey: urlKey,
            success: { myLocker in
                self.take(scanSec: scanSec, token: token, spacerId: myLocker.id, success: success, failure: failure)
            },
            failure: failure)
    }
}
