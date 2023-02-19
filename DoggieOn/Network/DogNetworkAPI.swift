//
//  DogsRequestModel.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/09.
//

import Foundation
import UIKit
import Alamofire

protocol DogNetworkProtocol {
    func fetchDogs(page: Int, completion: @escaping (Result<[Dog], ApiError>) -> Void)
    func fetchFavourites(completion: @escaping (Result<[Favourite], ApiError>) -> Void)
    func postFavourite(imageId: String, completion: @escaping (Result<PostFavourite, ApiError>) -> Void)
    func deleteFavourites(favouriteId: Int)
    func uploadImage(image: UIImage, completion: @escaping (Result<UploadResponseModel, ApiError>) -> Void)
    func loadMyDogImage(completion: @escaping (Result<[MyDog], ApiError>) -> Void)
}

enum ApiError: Error {
    case parsingError
    case noContent
    case decodingError
    case badStatus(code: Int)
    case urlMissing
}

struct DogNetworkAPI: DogNetworkProtocol {
    static let baseURL = "https://api.thedogapi.com/"

    func fetchDogs(page: Int, completion: @escaping (Result<[Dog], ApiError>) -> Void) {
        var components = URLComponents(string: DogNetworkAPI.baseURL + "v1/images/search")

        let mimeType = URLQueryItem(name: "mime_type", value: "jpg")
        let format = URLQueryItem(name: "format", value: "json")
        let hasBreeds = URLQueryItem(name: "has_breeds", value: "\(true)")
        let order = URLQueryItem(name: "order", value: "RANDOM")
        let page = URLQueryItem(name: "page", value: "\(page)")
        let limit = URLQueryItem(name: "limit", value: "\(20)")
        components?.queryItems = [mimeType, format, hasBreeds, order, page, limit]

        guard let url = components?.url else { return completion(.failure(.urlMissing)) }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.DOG_API_KEY, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let jsonData = data {
                do {
                    let data = try JSONDecoder().decode([Dog].self, from: jsonData)
                    completion(.success(data))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }

    func fetchFavourites(completion: @escaping (Result<[Favourite], ApiError>) -> Void) {
        let urlString = DogNetworkAPI.baseURL + "v1/favourites"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlMissing))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.DOG_API_KEY, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let jsonData = data {
                do {
                    let data = try JSONDecoder().decode([Favourite].self, from: jsonData)
                    completion(.success(data))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }

    func postFavourite(imageId: String, completion: @escaping (Result<PostFavourite, ApiError>) -> Void) {
        let urlString = DogNetworkAPI.baseURL + "v1/favourites"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlMissing))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.DOG_API_KEY, forHTTPHeaderField: "x-api-key")

        let requestParams: [String: String] = ["image_id": imageId, "sub_id": "victor123"]
        print(requestParams)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(.parsingError))
        }

        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let jsonData = data {
                do {
                    let data = try JSONDecoder().decode(PostFavourite.self, from: jsonData)
                    completion(.success(data))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }

    func deleteFavourites(favouriteId: Int) {
        let urlString = DogNetworkAPI.baseURL + "v1/favourites" + "/\(favouriteId)"
        guard let url = URL(string: urlString) else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.DOG_API_KEY, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: urlRequest)
        .resume()
    }

    func uploadImage(image: UIImage, completion: @escaping (Result<UploadResponseModel, ApiError>) -> Void) {
        let urlString = DogNetworkAPI.baseURL + "v1/images/upload"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlMissing))
        }

        let imageToData = image.jpegData(compressionQuality: 1)

        let header: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "x-api-key": Bundle.main.DOG_API_KEY
        ]

        let parameters = [
            "sub_id": "victor123"
        ]

        AF.upload(multipartFormData: { mutipartFormData in
            for (key, value) in parameters {
                mutipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }
            mutipartFormData.append(imageToData!, withName: "file", fileName: "a.jpg", mimeType: "image/jpeg")
        }, to: url, method: .post, headers: header)
        .responseData { response in
            if let jsonData = response.data {
                do {
                    let data = try JSONDecoder().decode(UploadResponseModel.self, from: jsonData)
                    completion(.success(data))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }
    }

    func loadMyDogImage(completion: @escaping (Result<[MyDog], ApiError>) -> Void) {
        let urlString = DogNetworkAPI.baseURL + "v1/images"
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlMissing))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.DOG_API_KEY, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let jsonData = data {
                do {
                    let data = try JSONDecoder().decode([MyDog].self, from: jsonData)
                    completion(.success(data))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }

}
