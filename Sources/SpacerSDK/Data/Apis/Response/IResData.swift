//
//  IResData.swift
//
//
//  Created by Takehito Soi on 2021/06/29.
//

import Foundation

protocol IResData: Codable {
    var result: Bool { set get }
    var error: ErrorResData? { set get }
}
