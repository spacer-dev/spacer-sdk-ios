//
//  AlertItem.swift
//  Example
//
//  Created by Takehito Soi on 2021/06/22.
//

import SpacerSDK
import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String?

    var alert: Alert {
        if let message = message {
            return Alert(title: Text(title), message: Text(message))
        } else {
            return Alert(title: Text(title))
        }
    }

    static func CBLockerScanSuccess(_ sprLockers: [SPRLockerModel]) -> AlertItem {
        let text = sprLockers.map { $0.description }.joined(separator: "\n")
        return AlertItem(title: "succeeded in scanning", message: "\(text)")
    }

    static func CBLockerPutSuccess(_ spacerId: String) -> AlertItem {
        AlertItem(title: "succeeded in putting in \(spacerId)")
    }

    static func CBLockerTakeSuccess(_ spacerId: String) -> AlertItem {
        AlertItem(title: "succeeded in taking from \(spacerId)")
    }
    
    static func CBLockerOpenForMaintenanceSuccess(_ spacerId: String) -> AlertItem {
        AlertItem(title: "succeeded in opening from \(spacerId)")
    }

    static func CBLockerTakeWithKeySuccess(_ urlKey: String) -> AlertItem {
        AlertItem(title: "succeeded in taking with \(urlKey)")
    }
    
    static func CBLockerReadSuccess(_ readData: String) -> AlertItem {
        AlertItem(title: "succeeded in reading", message: "\(readData)")
    }

    static func MyLockerGetSuccess(_ myLockers: [MyLockerModel]) -> AlertItem {
        let text = myLockers.map { $0.description }.joined(separator: "\n")
        return AlertItem(title: "succeeded in getting myLockers", message: "\(text)")
    }
    
    static func MyMaintenanceLockerGetSuccess(_ myMaintenanceLockers: [MyMaintenanceLockerModel]) -> AlertItem {
        let text = myMaintenanceLockers.map { $0.description }.joined(separator: "\n")
        return AlertItem(title: "succeeded in getting myMaintenanceLockers", message: "\(text)")
    }

    static func MyLockerReserveSuccess(_ spacerId: String, _ myLocker: MyLockerModel) -> AlertItem {
        AlertItem(title: "succeeded reservation of \(spacerId)", message: "\(myLocker.description)")
    }

    static func MyLockerReserveCancelSuccess(_ spacerId: String) -> AlertItem {
        AlertItem(title: "succeeded in canceling \(spacerId) reservation")
    }

    static func MyLockerShareUrlKeySuccess(_ urlKey: String, _ myLocker: MyLockerModel) -> AlertItem {
        AlertItem(title: "succeeded in sharing with \(urlKey)", message: "\(myLocker.description)")
    }

    static func SPRLockerGetSuccess(_ sprLockers: [SPRLockerModel]) -> AlertItem {
        let text = sprLockers.map { $0.description }.joined(separator: "\n")
        return AlertItem(title: "succeeded in getting spacers", message: "\(text)")
    }

    static func SPRUnitGetSuccess(_ sprUnits: [SPRLockerUnitModel]) -> AlertItem {
        let text = sprUnits.map { $0.description }.joined(separator: "\n")
        return AlertItem(title: "succeeded in getting units", message: "\(text)")
    }
    
    static func SPRLocationGetSuccess(_ sprLocation: LocationModel) -> AlertItem {
        AlertItem(title: "succeeded in getting location", message: sprLocation.description)
    }

    static func NoLocationPermits() -> AlertItem {
        AlertItem(title: "Permission to use location information is required", message: "Please allow the use of location information in the Settings app.")
    }
}
