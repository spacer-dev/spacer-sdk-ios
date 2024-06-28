//
//  ApiClient.swift
//
//
//  Created by Takehito Soi on 2021/06/24.
//
import Alamofire
import Foundation

class ApiClient {
    func get<T: IResData>(
        path: String,
        token: String,
        reqData: IReqData,
        success: @escaping (T) -> Void,
        failure: @escaping (SPRError) -> Void
    ) {
        AF.request(
            "\(ApiConst.BaseURL)/\(path)",
            method: .get,
            parameters: reqData.toParams(),
            encoding: URLEncoding.default,  // GET メソッドでは URLEncoding を使用します
            headers: createHeaders(token),
            requestModifier: { $0.timeoutInterval = ApiConst.TimeoutSec }
        ).responseJSON { response in

            switch response.result {
            case .failure(let error):
                print("request failed with error: \(error)")
                failure(SPRError.ApiFailed)
            case .success:
                do {
                    guard let data = response.data else { return failure(SPRError.ApiFailed) }

                    let codable = try JSONDecoder().decode(T.self, from: data)
                    if let error = codable.error { return failure(error.toSPRError()) }

                    success(codable)

                } catch {
                    print("request failed with error: \(error)")
                    failure(SPRError.ApiFailed)
                }
            }
        }
    }
    
    func post<T: IResData>(
        path: String,
        token: String,
        reqData: IReqData,
        success: @escaping (T) -> Void,
        failure: @escaping (SPRError) -> Void
    ) {
        AF.request(
            "\(ApiConst.BaseURL)/\(path)",
            method: .post,
            parameters: reqData.toParams(),
            encoding: JSONEncoding.default,
            headers: createHeaders(token),
            requestModifier: { $0.timeoutInterval = ApiConst.TimeoutSec }
        ).responseJSON { response in

            switch response.result {
            case .failure(let error):
                print("request failed with error: \(error)")
                failure(SPRError.ApiFailed)
            case .success:
                do {
                    guard let data = response.data else { return failure(SPRError.ApiFailed) }

                    let codable = try JSONDecoder().decode(T.self, from: data)
                    if let error = codable.error { return failure(error.toSPRError()) }

                    success(codable)

                } catch {
                    print("request failed with error: \(error)")
                    failure(SPRError.ApiFailed)
                }
            }
        }
    }

    private func createHeaders(_ token: String) -> HTTPHeaders {
        if ApiConst.ApiType == .app {
            return createAppHeaders(token)
        }
        return createExHeaders(token)
    }
    
    private func createExHeaders(_ token: String) -> HTTPHeaders {
        return [
            "Contenttype": "application/json",
            "X-Spacer-ExApp-Token": token
        ]
    }
    
    private func createAppHeaders(_ token: String) -> HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)",
            "X-App-Type": "SDK"
        ]
    }
}

let API = ApiClient()
