//
//  ResultViewController.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/07.
//

import UIKit
import RxSwift
import Kingfisher

class ResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel = ViewModel()
    
    var disposeBag = DisposeBag()
    
    var cityName:String
    
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    init(cityName: String) {
        self.cityName = cityName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(UINib(nibName: "WeekTableViewCell", bundle: nil), forCellReuseIdentifier: "WeekTableViewCell")
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionTableViewCell")
        tableView.register(UINib(nibName: "FooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "FooterView")
    }
}

extension ResultViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        debugPrint("ResultViewController numberOfSections(\(cityName))")
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.dayName.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as! CollectionTableViewCell
            
            activityIndicator.startAnimating()
            
            viewModel.dataForCell2(cityName: cityName)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak cell] cellData in
                    if let weatherDict = cellData["weatherDict"] as? [String: Any] {
                        if let mainDict = weatherDict["main"] as? [String: Any] {
                            cell?.mainData(with:mainDict)
                        }
                    }
                    self.activityIndicator.stopAnimating()
                }).disposed(by: disposeBag)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekTableViewCell", for: indexPath) as! WeekTableViewCell
            cell.dayName.text = viewModel.dayName[indexPath.row]
            
            guard let url = URL(string: "https://openweathermap.org/img/wn/\(viewModel.dayIcon[indexPath.row])@2x.png") else { return cell}
            
            cell.dayIcon.kf.setImage(with: url)
            cell.dayIcon.contentMode = .scaleAspectFill
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == 0 {
            return 250
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "7일간의 일기예보"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        
        if section == 0 {
            view.cityNameLabel.text = cityName
            
            viewModel.dataForCell2(cityName: cityName)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak view] cellData in
                    if let weatherDict = cellData["weatherDict"] as? [String: Any] {
                        if let weatherArray = weatherDict["weather"] as? [Any],
                           let weatherDictionary = weatherArray.first as? [String: Any] {
                            if let icon = weatherDictionary["icon"] as? String {
                                let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
                                if let url = URL(string: urlString) {
                                    view?.iconImageView.kf.setImage(with: url)
                                    view?.iconImageView.contentMode = .scaleAspectFill
                                }
                            }
                        }
                        
                        if let mainDict = weatherDict["main"] as? [String: Any],
                           let temp = mainDict["temp"] as? Double,
                           let minTemp = mainDict["temp_min"] as? Double,
                           let maxTemp = mainDict["temp_max"] as? Double {
                            view?.currentTempLabel.text = kToC(kelvin: temp)
                            view?.maxTempLabel.text = "최고 : \(kToC(kelvin: maxTemp))"
                            view?.minTempLabel.text = "최저 : \(kToC(kelvin: minTemp))"
                        }
                    }
                }).disposed(by: disposeBag)
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterView") as! FooterView
            
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if section == 0 {
            
            return 160
        }
        return UITableView.automaticDimension
    }
}
