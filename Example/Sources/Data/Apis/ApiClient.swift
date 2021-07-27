//
//  ApiClient.swift
//
//
//  Created by Takehito Soi on 2021/07/20.
//

import Alamofire
import Foundation
import SpacerSDK

class ApiClient {
    func post<T: IResData>(
        path: String,
        reqData: IReqData,
        success: @escaping (T) -> Void,
        failure: @escaping (ExampleError) -> Void
    ) {
        AF.request(
            "\(ApiConst.ApiBaseURL)/\(path)",
            method: .post,
            parameters: reqData.toParams(),
            encoding: JSONEncoding.default,
            headers: createHeaders(),
            requestModifier: { $0.timeoutInterval = ApiConst.TimeoutInterval }
        ).responseJSON { response in

            switch response.result {
            case .failure(let error):
                print("request failed with error: \(error)")
                failure(ExampleError.TestError)
            case .success:
                do {
                    guard let data = response.data else { return failure(ExampleError.TestError) }

                    let codable = try JSONDecoder().decode(T.self, from: data)
                    if let error = codable.error { return failure(error.toExampleError()) }

                    success(codable)

                } catch {
                    print("request failed with error: \(error)")
                    failure(ExampleError.TestError)
                }
            }
        }
    }

    private func createHeaders() -> HTTPHeaders {
        return [
            "Contenttype": "application/json"
        ]
    }
}

let API = ApiClient()
