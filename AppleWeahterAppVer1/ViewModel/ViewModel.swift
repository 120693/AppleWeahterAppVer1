//
//  ViewModel.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/02.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    var api = Api()
    
    let disposeBag = DisposeBag()
        
    var dayName: [String] = ["월","화","수","목","금","토","일"]
    var dayIcon: [String] = ["10d","01d","02d","03d","04d","11d","13d"]
    
    // api에서 받아온 데이터를 Dictionary로 바꾸는 함수 - 클로저 사용
    func apiToDict(cityName: String, completion: @escaping ([String:Any]) -> ()) {
        api.getApi(cityName: cityName) { result in
            switch result {
            case .success(let weatherModel):
                if let weatherDict = self.encodeModelToDictionary(model: weatherModel) {
                    completion(weatherDict)
                }
            case .failure(_):
                break
            }
        }
    }
    
    // api에서 받아온 데이터를 Dictionary로 바꾸는 함수 - RxSwift 사용
    func apiToDict2(cityName: String) -> Observable<[String:Any]> {
        return Observable.create() { [weak self] emitter in
            self?.api.getApi(cityName: cityName) { result in
                switch result {
                case .success(let weatherModel):
                    if let weatherDict = self?.encodeModelToDictionary(model: weatherModel) {
                        emitter.onNext(weatherDict)
                    }
                case .failure(_):
                    break
                }
            }
            return Disposables.create()
        }
    }
    
    // JSON -> Dictionary
    func encodeModelToDictionary<T: Codable>(model: T) -> [String: Any]? {
        guard let jsonData = try? JSONEncoder().encode(model) else {
               return nil
           }
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
               return nil
           }
        return dictionary
    }
    
    // 각 Cell별로 날씨 정보를 컨트롤
    func dataForCell2(cityName: String) -> Observable<[String: Any]> {
        return Observable.create() { [weak self] emitter in
            self?.apiToDict2(cityName: cityName)
                .subscribe(onNext: { weatherDict in
                    // 구독할 때 마다 cellData를 만들어야 함. 전역 선언 ㄴㄴ
                    let cellData = BehaviorRelay<[String: Any]>(value: [:]) // 변경을 추적해야함
                    cellData.accept(["cityName":cityName, "weatherDict":weatherDict])
                    // "cityName"과 "weatherDict" 키를 가지며, 해당 도시 이름과 날씨 정보를 담습니다.
                    emitter.onNext(cellData.value)
                    //print("cellData.value : \(cellData.value)")
                }).disposed(by: self!.disposeBag)
            return Disposables.create()
        }
    }    
}
