//
//  Sessions+CoreDataProperties.swift
//  
//
//  Created by Aghajanov Alex on 2024-06-11.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Sessions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sessions> {
        return NSFetchRequest<Sessions>(entityName: "Sessions")
    }

    @NSManaged public var averageSpeed: Int16
    @NSManaged public var date: Date?
    @NSManaged public var numberOfShots: Int16
    @NSManaged public var targets: String?
    @NSManaged public var unit: String?
    @NSManaged public var uuid: UUID?

}

extension Sessions : Identifiable {

}
