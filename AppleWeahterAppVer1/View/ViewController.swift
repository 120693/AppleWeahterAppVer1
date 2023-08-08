//
//  ViewController.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/01.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ViewModel()
    
    let disposeBag = DisposeBag()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var cityNames = [CityName]() // CityName 저장하는 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "날씨"
        
        getAllCityNames()
                
//        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func Button(_ sender: UIButton) {
        let cityName = cityNameTextField.text!
        createCityName(cityName: cityName)
    }
    
    func getAllCityNames() {
        do {
            cityNames = try context.fetch(CityName.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }
    
    func createCityName(cityName: String) {
        let newCityName = CityName(context: context)
        newCityName.cityName = cityName
        
        do {
            try context.save()
            getAllCityNames()
            
        }
        catch {
            
        }
    }
    
    func deleteCityName(cityName: CityName) {
        context.delete(cityName)
        
        do {
            try context.save()
            getAllCityNames()
        }
        catch {
            
        }
    }
}

public func kToC(kelvin: Double) -> String {
    let celsius: Double
    let result: String
    
    celsius = kelvin - 273.15
    
    result = String(format:"%.2f", celsius) + "°C"
    
    return result
}

public func kToCInt(kelvin: Double) -> String {
    let celsius: Double
    let result: String
    
    celsius = kelvin - 273.15
    
    result = String(format:"%.0f", celsius) + "°C"
    
    return result
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        let cityName = cityNames[indexPath.row]
        
        if let cityNameForApi = cityName.cityName {
            
            cell.cityNameLabel.text = cityNameForApi
            
            viewModel.dataForCell2(cityName: cityNameForApi)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak cell] cellData in
                    if let weatherDict = cellData["weatherDict"] as? [String: Any] {
                        //print("weatherModel: \(weatherDict)")
                        
                        if let mainDict = weatherDict["main"] as? [String: Any],
                           let temp = mainDict["temp"] as? Double,
                           let minTemp = mainDict["temp_min"] as? Double,
                           let maxTemp = mainDict["temp_max"] as? Double {
                            cell?.currentTemp.text = kToC(kelvin: temp)
                            cell?.minMaxTemp.text = "최고 : \(kToCInt(kelvin: maxTemp)) / " + "최저 : \(kToCInt(kelvin: minTemp))"
                        }
                        
                        if let weatherArray = weatherDict["weather"] as? [Any],
                           let weatherDictionary = weatherArray.first as? [String: Any] {
                            if let weatherDescription = weatherDictionary["description"] as? String {
                                cell?.weatherDescription.text = weatherDescription
                            }
                        }
                        
                    }
                }).disposed(by: disposeBag)
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let cityName = cityNames[indexPath.row]
        
        if editingStyle == .delete {
            deleteCityName(cityName: cityName)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제" // 원하는 대체 문자열로 변경
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // 선택 상태 해제
        
        let selectedCity = cityNames[indexPath.row]
        
        var viewsList: [UIViewController] = []
        
        let targetIndex = cityNames.firstIndex(where: { $0 == selectedCity }) ?? 0

        for cityName in cityNames {
            let resultViewController = ResultViewController(cityName: cityName.cityName!)
            viewsList.append(resultViewController)
        }
                
        let pageViewController = PageViewController(viewsList: viewsList, targetIndex: targetIndex)
        self.navigationController?.pushViewController(pageViewController, animated: true)
    }
}
