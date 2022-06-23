//
//  Provides basic location information
//  
//
//  Created by s.norimatsu on 2022/06/09.
//

import Foundation

public class LocationService {
    /// Get location basic information
    /// - Parameters:
    ///   - token: User token created on the server
    ///   - locationId: Location ID, ex) "location101"
    ///   - success: Callback on success
    ///   - failure: Callback on failure
    public func get(token: String, locationId: String, success: @escaping (LocationModel) -> Void, failure: @escaping (SPRError) -> Void) {
        let reqData = LocationGetReqData(locationId: locationId)

        API.post(
            path: ApiPaths.LocationGet,
            token: token,
            reqData: reqData,
            success: { (response: LocationGetResData) in
                guard let locationResData = response.location else { return failure(SPRError.ApiFailed) }
                let location = locationResData.toModel()
                success(location)
            },
            failure: failure)
    }
}
