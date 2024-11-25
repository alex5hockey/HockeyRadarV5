//
//  SettingsInfo+CoreDataProperties.swift
//  
//
//  Created by Aghajanov Alex on 2024-06-11.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SettingsInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsInfo> {
        return NSFetchRequest<SettingsInfo>(entityName: "SettingsInfo")
    }

    @NSManaged public var hapticFeedback: Bool
    @NSManaged public var shotDirection: Bool
    @NSManaged public var speedUnits: String?

}

extension SettingsInfo : Identifiable {

}
