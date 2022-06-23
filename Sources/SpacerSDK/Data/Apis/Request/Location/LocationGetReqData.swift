//
//  LocationGetReqData.swift
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

struct LocationGetReqData: IReqData {
    var locationId: String

    func toParams() -> [String: Any] {
        [
            "locationId": locationId
        ]
    }
}
