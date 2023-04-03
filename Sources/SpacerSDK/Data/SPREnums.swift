//
//  SPREnums.swift
//  
//
//  Created by s.norimatsu on 2023/03/10.
//

import Foundation

public enum ApiType {
    case ex
    case app
    
    init?(value: String) {
        switch value {
        case "app":
            self = .app
        default:
            self = .ex
        }
    }
}
