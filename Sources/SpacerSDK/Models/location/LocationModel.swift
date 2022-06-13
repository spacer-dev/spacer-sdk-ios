//
//  LocationModel.swift
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

public struct LocationModel: Identifiable {
    public var id: String
    public var name: String
    public var address: String
    public var detail: String
    public var open: String?
    public var close: String?
    public var units: [SPRLockerUnitModel]?
    
    public var description: String {
        "id:\(id),name:\(name),address:\(address),detail:\(detail),open:\(open ?? ""),close:\(close ?? ""),units:\(units ?? [])"
    }
}

extension LocationResData {
    func toModel() -> LocationModel {
        let units = units?.map { $0.toModel() }
        return LocationModel(id: id, name: name, address: address, detail: detail, open: open, close: close, units: units)
    }
}
