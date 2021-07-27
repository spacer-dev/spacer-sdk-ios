//
//  IReqData.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

protocol IReqData {
    func toParams() -> [String: Any]
}
