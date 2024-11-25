//
//  Targets+CoreDataProperties.swift
//  
//
//  Created by Aghajanov Alex on 2024-06-11.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Targets {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Targets> {
        return NSFetchRequest<Targets>(entityName: "Targets")
    }

    @NSManaged public var target: String?

}

extension Targets : Identifiable {

}
