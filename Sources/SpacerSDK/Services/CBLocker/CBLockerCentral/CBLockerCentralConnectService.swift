//
//  CBLockerCentralConnectService.swift
//
//
//  Created by Takehito Soi on 2021/06/23.
//

import CoreBluetooth
// <追加>
import CoreLocation

import Foundation
// <追加>
import UIKit

class CBLockerCentralConnectService: NSObject {
    private var token: String!
    private var spacerId: String!
    private var type: CBLockerActionType!
    private var connectable: (CBLockerModel) -> Void = { _ in }
    private var success: () -> Void = {}
//  [変更前]
    private var readSuccess: (String) -> Void = { _ in }
//  [変更後]
//  private var readSuccess: (Bool) -> Void = { _ in }
    private var failure: (SPRError) -> Void = { _ in }
//  <追加>
//  private let sprLockerService = SPR.sprLockerService()
//  private let httpLockerService = HttpLockerService()
    
    private var centralService: CBLockerCentralService?
    private var isCanceled = false
    
//  <追加>
//  private var locationManager = CLLocationManager()
//  private var isExecutingHttpService = false
//  private var hasBLERetried = false
//  private var isPermitted = false
//  private let httpFallbackErrors = [
//      SPRError.CBServiceNotFound,
//      SPRError.CBCharacteristicNotFound,
//      SPRError.CBReadingCharacteristicFailed,
//      SPRError.CBConnectStartTimeout,
//      SPRError.CBConnectDiscoverTimeout,
//      SPRError.CBConnectReadTimeoutBeforeWrite
//  ]
//
//  private var notAvailableReadData = ["openedExpired", "openedNotExpired", "closedExpired", "false"]

    override init() {
        super.init()
        centralService = CBLockerCentralService(delegate: self)
//      <追加>
//      locationManager.delegate = self
//      locationManager.desiredAccuracy = kCLLocationAccuracyBest
//      let status = CLLocationManager.authorizationStatus()
//      isPermitted = status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    private func scan() {
        centralService?.startScan()
    }
    
    func put(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .put
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func take(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .take
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
    func openForMaintenance(token: String, spacerId: String, success: @escaping () -> Void, failure: @escaping (SPRError) -> Void) {
        self.token = token
        self.spacerId = spacerId
        type = .openForMaintenance
        connectable = { locker in self.connectWithRetry(locker: locker) }
        self.success = success
        self.failure = failure

        scan()
    }
    
//  [変更前]
    func read(spacerId: String, success: @escaping (String) -> Void, failure: @escaping (SPRError) -> Void) {
//  [変更後]
//  func checkDoorStatusAvailable(token: String, spacerId: String, success: @escaping (Bool) -> Void, failure: @escaping (SPRError) -> Void) {
//      self.token = token
        self.spacerId = spacerId
        
//      [変更前]
        self.type = .read
        self.connectable = { locker in self.connectWithRetryByRead(locker: locker) }
        self.readSuccess = success
//      [変更後]
//      type = .checkDoorStatusAvailable
//      connectable = { locker in self.checkDoorStatusAvailable(locker: locker) }
//      readSuccess = success
        self.failure = failure

        scan()
    }

//    <追加>
//    private func updateHttpSupportStatus(locker: CBLockerModel, success: @escaping (CBLockerModel) -> Void, failure: @escaping (SPRError) -> Void) {
//        sprLockerService.getLocker(
//            token: token,
//            spacerId: spacerId,
//            success: { spacer in
//                var locker = locker
//                locker.isHttpSupported = spacer.isHttpSupported
//                success(locker)
//            },
//            failure: failure
//        )
//    }

    private func connectWithRetry(locker: CBLockerModel, retryNum: Int = 0) {
//        <追加>
//        if locker.isHttpSupported, !locker.isScanned, isPermitted {
//            locationManager.requestLocation()
//        } else {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        let peripheralDelegate =
            CBLockerPeripheralService.Factory.create(
                type: type, token: token, locker: locker, isRetry: retryNum > 0, success: {
                    self.success()
                    self.disconnect(locker: locker)
                },
                failure: { error in
//                        <追加>
//                        if locker.isHttpSupported, !self.hasBLERetried, self.httpFallbackErrors.contains(error), self.isPermitted {
//                            self.locationManager.requestLocation()
//                        } else {
                    self.retryOrFailure(
                        error: error,
                        locker: locker,
                        retryNum: retryNum + 1,
                        executable: { self.connectWithRetry(locker: locker, retryNum: retryNum + 1) }
                    )
//                        }
                }
            )

        guard let delegate = peripheralDelegate else { return failure(SPRError.CBConnectingFailed) }

        locker.peripheral?.delegate = delegate
        delegate.startConnectingAndDiscoveringServices()
        centralService?.connect(peripheral: peripheral)
//        }
    }
    
//  [変更前]
    private func connectWithRetryByRead(locker: CBLockerModel, retryNum: Int = 0) {
//  [変更後]
//  private func checkDoorStatusAvailable(locker: CBLockerModel) {
//        <追加>
//        if locker.isScanned {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        let peripheralDelegate =
            CBLockerPeripheralReadService(
                locker: locker, success: { readData in
//                  [変更前]
                    self.readSuccess(readData)
//                  [変更後]
//                  self.readSuccess(!self.notAvailableReadData.contains(readData))
                    self.disconnect(locker: locker)
                },
//              [変更前]
                failure: { error in
//              [変更後]
//              failure: { _ in
                    
//                  [変更前]
                    self.retryOrFailure(
                        error: error,
                        locker: locker,
                        retryNum: retryNum + 1,
                        executable: { self.connectWithRetryByRead(locker: locker, retryNum: retryNum + 1) }
                    )
//                  [変更後]
//                  self.readSuccess(locker.isHttpSupported)
                }
            )

        let delegate = peripheralDelegate

        locker.peripheral?.delegate = delegate
        delegate.startConnectingAndDiscoveringServices()
        centralService?.connect(peripheral: peripheral)
//        <追加>
//        } else {
//            readSuccess(locker.isHttpSupported)
//        }
    }
    
    private func retryOrFailure(error: SPRError, locker: CBLockerModel, retryNum: Int, executable: @escaping () -> Void) {
        if retryNum < CBLockerConst.MaxRetryNum {
//          <追加>
//          hasBLERetried = true
            executable()
        } else {
            failure(error)
            disconnect(locker: locker)
        }
    }
    
    private func disconnect(locker: CBLockerModel) {
        guard let peripheral = locker.peripheral else { return failure(SPRError.CBPeripheralNotFound) }
        centralService?.disconnect(peripheral: peripheral)
    }

//    <追加>
//    func httpLockerServices(lat: Double?, lng: Double?) {
//        if type == .put {
//            httpLockerService.put(
//                token: token,
//                spacerId: spacerId,
//                lat: lat,
//                lng: lng,
//                success: success,
//                failure: { error in self.failure(error) }
//            )
//        } else if type == .take {
//            httpLockerService.take(
//                token: token,
//                spacerId: spacerId,
//                lat: lat,
//                lng: lng,
//                success: success,
//                failure: { error in self.failure(error) }
//            )
//        } else if type == .openForMaintenance {
//            httpLockerService.openForMaintenance(
//                token: token,
//                spacerId: spacerId,
//                lat: lat,
//                lng: lng,
//                success: success,
//                failure: { error in self.failure(error) }
//            )
//        }
//    }
}

extension CBLockerCentralConnectService: CBLockerCentralDelegate {
    func execAfterDiscovered(locker: CBLockerModel) {
        if locker.id == spacerId {
            centralService?.stopScan()
            successIfNotCanceled(locker: locker)
        }
    }
    
    func execAfterScanning(lockers: [CBLockerModel]) -> Bool {
        return centralService?.isScanning == false
    }
    
    func successIfNotCanceled(locker: CBLockerModel) {
        centralService?.stopScan()

        if !isCanceled {
            isCanceled = true
//          [変更前]
            connectable(locker)
//          [変更後]
//          var locker = locker
//          locker.isScanned = true
//          updateHttpSupportStatus(locker: locker, success: connectable, failure: failure)
        }
    }

    func failureIfNotCanceled(_ error: SPRError) {
        centralService?.stopScan()

        if !isCanceled {
            isCanceled = true
//          [変更前]
            failure(error)
//          [変更後]
//          let locker = CBLockerModel(id: spacerId)
//          updateHttpSupportStatus(
//              locker: locker,
//              success: { locker in
//                  if locker.isHttpSupported, self.isPermitted {
//                      self.connectable(locker)
//                  } else {
//                      self.failure(error)
//                  }
//              },
//              failure: failure
//          )
        }
    }
}

//<追加>
//extension CBLockerCentralConnectService: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            let lat = location.coordinate.latitude
//            let lng = location.coordinate.longitude
//            if !isExecutingHttpService {
//                isExecutingHttpService = true
//                httpLockerServices(lat: lat, lng: lng)
//            }
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        if !isExecutingHttpService {
//            isExecutingHttpService = true
//            httpLockerServices(lat: nil, lng: nil)
//        }
//    }
//}
