//
//  SpacerService.swift
//  Example
//
//  Created by Takehito Soi on 2021/07/19.
//

import Foundation

class SpacerService {
    /// This method obtains a token with a test API key and a test user ID to check the operation.
    /// When embedding the SDK in your application, please obtain a user-unique token for SPACER authentication from your server.
    ///
    /// Please refer to the following document for how to get the token.
    ///   https://www.notion.so/API-a065d5ee671340dfb63eaf10a7a7c14b
    ///
    /// - Parameters:
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    func getToken(success: @escaping (String) -> Void, failure: @escaping (ExampleError) -> Void) {
        let reqData = UserTokenReqData(apiKey: ApiConst.ApiKey, userId: ApiConst.ApiUserId)

        API.post(
            path: ApiPaths.userToken,
            reqData: reqData,
            success: { (resData: UserTokenResData) in
                success(resData.token!)
            },
            failure: failure)
    }
}
