//
//  Shots+CoreDataProperties.swift
//  
//
//  Created by Aghajanov Alex on 2024-06-11.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Shots {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shots> {
        return NSFetchRequest<Shots>(entityName: "Shots")
    }

    @NSManaged public var accurate: Bool
    @NSManaged public var sessionUUID: UUID?
    @NSManaged public var shotX: Float
    @NSManaged public var shotY: Float
    @NSManaged public var speed: Int16
    @NSManaged public var target: String?
    @NSManaged public var unit: String?

}

extension Shots : Identifiable {

}
