//
//  Helpers.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-09-20.
//

import Foundation
import UIKit

//haptic feedback
func haptic(){
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
