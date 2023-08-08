//
//  Api.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/02.
//

import Foundation

enum MyError: Error {
    case invalidURL
    case noDataReceived
    case parsingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .noDataReceived:
            return "데이터를 수신하지 못했습니다."
        case .parsingError:
            return "데이터 파싱에 실패했습니다."
        }
    }
}

class Api {
    func getApi(cityName: String, completion: @escaping (Result<WeatherModel, MyError>) -> ()) {
        var components = URLComponents()
        let scheme = "https"
        let host = "api.openweathermap.org"
        let apiKey = "a8c1d55d8c112dbe5f0576f243f507ac"
        
        components.scheme = scheme
        components.host = host
        components.path = "/data/2.5/weather"
        components.queryItems = [URLQueryItem(name: "q", value: cityName), URLQueryItem(name: "appid", value: apiKey)]
        
        // url 확인
        guard let url = components.url else {
            completion(.failure(MyError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(MyError.invalidURL))
                return
            }
            
            // data 확인
            guard let data = data else {
                completion(.failure(MyError.noDataReceived))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let weatherModel = try decoder.decode(WeatherModel.self, from: data)
                completion(.success(weatherModel))
            }
            catch {
                completion(.failure(MyError.parsingError))
            }
        }
        
        task.resume()
    }
}
