//
//  IReqData.swif
//
//
//  Created by Takehito Soi on 2021/06/24.
//

import Foundation

protocol IReqData {
    func toParams() -> [String: Any]
}
