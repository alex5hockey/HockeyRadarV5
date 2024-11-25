//
//  IntroViewController.swift
//  HockeyRadarV2
//
//  Created by Alex Aghajanov on 2023-05-04.
//

import UIKit
import AVFoundation
import CoreData

class IntroViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var player: AVAudioPlayer?
    var fetchResultController: NSFetchedResultsController<CalibrationInfo>!
    var numberOfShotsToPass: Int = 0


    @IBOutlet weak var infoButton: UIButton!{
        didSet{
            infoButton.layer.cornerRadius = 5
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func sessionHistoryTapped(_ sender: Any) {
        haptic()
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        haptic()
    }
    @IBAction func howToStartTapped(_ sender: Any) {
        haptic()
    }
    
    
    @IBAction func speedModeTapped(_ sender: Any) {
        //TODO: Check if there are any saved calibrations, such as if the user just downloaded the app.
        
        haptic()
        let needsCalibration = self.checkForCalibrations()
        if !needsCalibration
        {
            self.performSegue(withIdentifier: "speedcalibrate", sender: self)
        }
        else
        {
            let alert = UIAlertController(title: "Begin Speed Testing?", message: "What would you like to do?", preferredStyle: .actionSheet)
            
            let start = UIAlertAction(title: "Begin Speed Session", style: .default) { action in
                self.performSegue(withIdentifier: "startspeed", sender: self)
            }
            let calibrate = UIAlertAction(title: "Calibrate", style: .default) { action in
                self.performSegue(withIdentifier: "speedcalibrate", sender: self)
            }
            /*
            let numberedShooting = UIAlertAction(title: "Numbered shots", style: .default) { action in
                let alert2 = UIAlertController(title: "Number of Shots", message: "How many shots would you like to do?", preferredStyle: .alert)
                alert2.addTextField { textField in
                    textField.keyboardType = .numberPad
                    textField.placeholder = "Enter a number"
                }
                let textField = alert.textFields![0]
                let number = UIAlertAction(title: "Proceed", style: .default)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                self.numberOfShotsToPass = Int(textField.text)
                
                alert2.addAction(number)
                
            }
             
             */
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            alert.addAction(start)
            //alert.addAction(numberedShooting)
            alert.addAction(calibrate)
            if UIDevice.current.userInterfaceIdiom == .pad {
                // The current device is an iPad
                print("ipad")
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if let popup = alert.popoverPresentationController {
                           popup.sourceView = self.view
                           popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                    }
                }
            }
            self.present(alert,animated: true)
        }
        
        
    }
    
    
    
    
    @IBAction func feedbackButton(_ sender: UIButton) {
        haptic()
        let alert = UIAlertController(title: "Help Improve HockeyRadar!", message: "The model for detecting pucks can be improved. If you are having trouble with your current hockey setup, consider sending a video of you taking up to 5 shots, on Google Drive! Ensure you have the same camera angle as required in calibration. I will personally communicate with you to improve compatibility with your setup. In the next update, these shots will be added to the AI that detects pucks, and you can expect much better results!", preferredStyle: .alert)
        let back = UIAlertAction(title: "Back", style: .cancel)
        let copyEmail = UIAlertAction(title: "Copy Email", style: .default) { action in
            UIPasteboard.general.string = "hockeyradarapp@gmail.com"
        }
        alert.addAction(back)
        alert.addAction(copyEmail)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // The current device is an iPad
            print("ipad")
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = alert.popoverPresentationController {
                       popup.sourceView = self.view
                       popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }
        }
        self.present(alert, animated: true)
        
        
    }
    
    
    
    
    func checkForCalibrations() -> Bool{
        //fetch previous calibrations and delete them
        let fetchRequest: NSFetchRequest<CalibrationInfo> = CalibrationInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "personToCamera", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects{
                    
                    if fetchedObjects.count == 0
                    {
                        print("none")
                        return false
                    }
                    else if fetchedObjects.count == 1
                    {
                        print("one")
                        return true
                    }
                    else
                    {
                        //delete the previous ones then require a new calibration
                        
                        for object in fetchedObjects {
                            context.delete(object)
                            print("deleted one")
                        }
                        
                        appDelegate.saveContext()
                        print("multiple")
                        return false
                        
                    }
                    
                    
                    
                }
            } catch {
                //default to needing a calibration, if there are multiple we will handle that later
                return false
            }
        }
        return false
    }
    
    
    @IBAction func shopTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "shop", sender: self)
        
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        /*
        if segue.identifier == "20shot"
        {
            let destinationViewController = segue.destination as! ViewController
            destinationViewController.numberOfShots == self.numberOfShotsToPass
            
            
        }
         */
        
    }
    

}
