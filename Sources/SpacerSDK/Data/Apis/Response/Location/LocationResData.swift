//
//  LocationResData.swift
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

struct LocationResData: Codable {
    var id: String
    var name: String
    var address: String
    var detail: String
    var open: String?
    var close: String?
    var units: [SPRLockerUnitResData]?
}
