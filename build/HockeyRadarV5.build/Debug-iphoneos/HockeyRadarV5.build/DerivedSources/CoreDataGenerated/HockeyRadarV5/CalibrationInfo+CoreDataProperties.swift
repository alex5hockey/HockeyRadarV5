//
//  CalibrationInfo+CoreDataProperties.swift
//  
//
//  Created by Aghajanov Alex on 2024-06-11.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CalibrationInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalibrationInfo> {
        return NSFetchRequest<CalibrationInfo>(entityName: "CalibrationInfo")
    }

    @NSManaged public var personToCamera: Int16
    @NSManaged public var personToNet: Int16

}

extension CalibrationInfo : Identifiable {

}
