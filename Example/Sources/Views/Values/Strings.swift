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
    static let CBLockerScanDesc = "use bluetooth to detect locker in front of you."

    static let CBLockerPutTitle = "put in locker"
    static let CBLockerPutDesc = "connect to locker with bluetooth and put your luggage in locker."
    static let CBLockerPutTextHint = "spacer id"

    static let CBLockerTakeTitle = "take from locker"
    static let CBLockerTakeDesc = "connect to locker with bluetooth and take luggage from locker."
    static let CBLockerTakeTextHint = "spacer id"
    static let CBLockerTakeSuccessTitle = "succeeded in taking"

    static let CBLockerTakeWithKeyTitle = "take from locker with url key"
    static let CBLockerTakeWithKeyDesc = "connect to locker with bluetooth and take luggage from locker with url key."
    static let CBLockerTakeWithKeyTextHint = "url key"

    static let MyLockerGetTitle = "get my lockers"
    static let MyLockerGetDesc = "get a list of your lockers in use."

    static let MyLockerReserveTitle = "reserve locker"
    static let MyLockerReserveDesc = "reserve available locker."
    static let MyLockerReserveTextHint = "spacer id"

    static let MyLockerReserveCancelTitle = "cancel reservation"
    static let MyLockerReserveCancelDesc = "cancel locker you reserved."
    static let MyLockerReserveCancelTextHint = "spacer id"

    static let MyLockerShareUrlKeyTitle = "share locker"
    static let MyLockerShareUrlKeyDesc = "share locker with yourself using url key."
    static let MyLockerShareUrlKeyTextHint = "url key"

    static let SPRLockerGetTitle = "get lockers"
    static let SPRLockerGetDesc = "get multiple locker basic information."
    static let SPRLockerGetTextHint = "spacer ids separated by commas"

    static let SPRUnitGetTitle = "get locker units"
    static let SPRUnitGetDesc = "get multiple locker unit basic information."
    static let SPRUnitGetTextHint = "unit ids separated by commas"
    
    static let SPRLocationGetTitle = "get location"
    static let SPRLocationGetDesc = "get multiple unit location basic information."
    static let SPRLocationGetTextHint = "location id"
}
