//
//  TableViewCell.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/03.
//

import UIKit

class TableViewCell: UITableViewCell {

    static let id = "TableViewCell"
    
    let cityNameLabel = UILabel()
    let currentTemp = UILabel()
    let minMaxTemp = UILabel()
    let weatherDescription = UILabel()
    
//    @IBOutlet weak var cityNameLabel: UILabel!
//    @IBOutlet weak var currentTemp: UILabel!
//    @IBOutlet weak var minMaxTemp: UILabel!
//    @IBOutlet weak var weatherDescription: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5))
    }
    
    func setUp() {
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(currentTemp)
        contentView.addSubview(minMaxTemp)
        contentView.addSubview(weatherDescription)
        
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cityNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cityNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cityNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -55),
            cityNameLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        cityNameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        currentTemp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTemp.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            currentTemp.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        currentTemp.font = UIFont.boldSystemFont(ofSize: 40)
        
        weatherDescription.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherDescription.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 25),
            weatherDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])
        
        minMaxTemp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minMaxTemp.topAnchor.constraint(equalTo: weatherDescription.topAnchor),
            minMaxTemp.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 2.0
    }
}
