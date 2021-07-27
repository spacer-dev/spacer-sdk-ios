//
//  UserTokenResData.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Foundation

struct UserTokenResData: IResData {
    var token: String?
    var result: Bool
    var error: ErrorResData?
}
