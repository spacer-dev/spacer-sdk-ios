//
//  LocationGetResData.swift
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

struct LocationGetResData: IResData {
    var location: LocationResData?
    var result: Bool
    var error: ErrorResData?
}
