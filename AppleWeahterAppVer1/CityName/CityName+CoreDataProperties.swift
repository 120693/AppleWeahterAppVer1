//
//  CityName+CoreDataProperties.swift
//  AppleWeahterAppVer1
//
//  Created by jhchoi on 2023/08/01.
//
//

import Foundation
import CoreData


extension CityName {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityName> {
        return NSFetchRequest<CityName>(entityName: "CityName")
    }

    @NSManaged public var cityName: String?

}

extension CityName : Identifiable {

}
