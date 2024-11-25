//
//  ToDo.swift
//  HockeyRadarV2
//
//  Created by Alex Aghajanov on 2023-05-05.
//

/*
 TODO:
 
 userdefaults key:
 
 let speedUnit = UserDefaults.standard.string(forKey: "speedUnit") ?? "kph"
 let shotDirection = UserDefaults.standard.string(forKey: "shotDirection") ?? "leftToRight"
 let hapticFeedback = UserDefaults.standard.bool(forKey: "hapticFeedback")
 let modelVersion = UserDefaults.standard.string(forKey: "modelVersion") ?? "Basic"
 let subscription = UserDefaults.standard.bool(forKey: "subscription")
 
 
 
 
 CURRENT TASK:
 add account system
 
 
 
 
 
 improving model more



 
 NEXT UP:
 add basic outline of a shop, with a link to ordering pink pucks from me
 
 
 revamp settings: Use userdefaults
 adding shot direction setting
 adding haptic feedback setting
 adding model version setting
 
 
 detect posts instead of using bounding box of the net, which is a rectangle. this will be estimated using the camera height, which needs to be added in calibration. closer to the ground, then the bottom of the net looks flat and the top is about 40% smaller on the far side. closer to the crossbar, then the crossbar looks flat in the camera and the bottom is about 40% shorter on the far side. this is good enough.
 
 
 
 
 
 BUGS:
  
 
 
 Updates Wishlist:
 add accuracy tracking, was removed for initial version
 add both ways shooting
 add 20 shots game mode
 

 
 
 
 
 

 
 
 
 
 */
