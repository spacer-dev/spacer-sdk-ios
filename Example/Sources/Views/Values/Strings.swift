//
//  Strings.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation
import SpacerSDK

class Strings {
    static let DefaultBtnText = "exec"

    static let CBLockerService = "CB Locker Service"
    static let MyLockerService = "My Locker Service"
    static let SPRLockerService = "SPR Locker Service"

    static let TabCBLockerName = "CBLocker"
    static let TabCBLockerIcon = "1.square.fill"

    static let TabMyLockerName = "MyLocker"
    static let TabMyLockerIcon = "2.square.fill"

    static let TabSPRLockerName = "SPRLocker"
    static let TabSPRLockerIcon = "3.square.fill"

    static let CBLockerScanTitle = "scan lockers"
    static let CBLockerScanDesc = "use bluetooth to detect the locker in front of you."

    static let CBLockerPutTitle = "put in locker"
    static let CBLockerPutDesc = "connect to the locker with bluetooth and put your luggage in the locker."
    static let CBLockerPutTextHint = "please enter spacer id"

    static let CBLockerTakeTitle = "take from locker"
    static let CBLockerTakeDesc = "connect to the locker with bluetooth and take the luggage from the locker."
    static let CBLockerTakeTextHint = "please enter spacer id"
    static let CBLockerTakeSuccessTitle = "succeeded in taking"

    static let CBLockerTakeWithKeyTitle = "take from locker with url key"
    static let CBLockerTakeWithKeyDesc = "connect to the locker with bluetooth and take the luggage from the locker with url key."
    static let CBLockerTakeWithKeyTextHint = "please enter url key"

    static let MyLockerGetTitle = "get my lockers"
    static let MyLockerGetDesc = "get a list of your lockers in use."

    static let MyLockerReserveTitle = "reserve locker"
    static let MyLockerReserveDesc = "reserve available locker."
    static let MyLockerReserveTextHint = "please enter spacer id"

    static let MyLockerReserveCancelTitle = "cancel reservation"
    static let MyLockerReserveCancelDesc = "cancel the locker you reserved."
    static let MyLockerReserveCancelTextHint = "please enter spacer id"

    static let MyLockerSharedTitle = "share locker"
    static let MyLockerSharedDesc = "share the locker with yourself using the url key."
    static let MyLockerSharedTextHint = "please enter url key"

    static let SPRLockerGetTitle = "get lockers"
    static let SPRLockerGetDesc = "get multiple locker basic information."
    static let SPRLockerGetTextHint = "please enter spacer ids separated by commas"

    static let SPRUnitGetTitle = "get locker units"
    static let SPRUnitGetDesc = "get multiple locker unit basic information."
    static let SPRUnitGetTextHint = "please enter unit ids separated by commas"
}
