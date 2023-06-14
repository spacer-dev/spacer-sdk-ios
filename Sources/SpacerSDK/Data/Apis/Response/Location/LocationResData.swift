//
//  LocationResData.swift
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

struct LocationResData: Codable {
    public var id: String
    public var name: String
    public var address: String
    public var detail: String
    public var open: String?
    public var close: String?
    public var doorWaitType: String
    public var units: [SPRLockerUnitResData]?
}
