//
//  SettingsTableViewController.swift
//  HockeyRadarV2
//
//  Created by Alex Aghajanov on 2023-05-09.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var hapticFeedbackLabel: UILabel!
    @IBOutlet weak var modelVersionLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    
    
    var fetchResultController: NSFetchedResultsController<SettingsInfo>!

    var fetchedSettings: [SettingsInfo] = []
    
    
    
    
    
     
     
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSettings()
        self.navigationController?.navigationBar.tintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Functions
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }

    func fetchSettings(){
        //fetch userdefaults and save
        
        let speedUnit = UserDefaults.standard.string(forKey: "speedUnit") ?? "kph"
        let shotDirection = UserDefaults.standard.string(forKey: "shotDirection") ?? "leftToRight"
        let hapticFeedback = UserDefaults.standard.bool(forKey: "hapticFeedback")
        let modelVersion = UserDefaults.standard.string(forKey: "modelVersion") ?? "Basic"
        let subscription = UserDefaults.standard.bool(forKey: "subscription")

        //update labels
        if speedUnit == "kph"{
            self.speedLabel.text = "Kilometers per Hour"
        }else if speedUnit == "mph"{
            self.speedLabel.text = "Miles per Hour"
        }else{
            self.speedLabel.text = "Meters per Second"
        }
        
        if shotDirection == "leftToRight"{
            self.directionLabel.text = "Left to Right"
        }else{
            self.directionLabel.text = "Right to Left"
        }
        
        if hapticFeedback{
            self.hapticFeedbackLabel.text = "On"
        }else{
            self.hapticFeedbackLabel.text = "Off"
        }
        if modelVersion == "Basic"{
            self.modelVersionLabel.text = "Basic: Black Pucks"
        }else{
            self.modelVersionLabel.text = "Advanced: Pink Pucks"
        }
        if subscription{
            subscriptionLabel.text = "Using Pro Features"
        }else if !subscription{
            subscriptionLabel.text = "Using Basic Features"
        }else{
            subscriptionLabel.text = "idk"
        }

    }

    
    
    
    //MARK: Speed changing
    
    @IBAction func changeSpeedUnitTapped(_ sender: Any) {
        haptic()
        let alert = UIAlertController(title: "Unit of Speed", message: "What unit of speed would you like?", preferredStyle: .actionSheet)
        let kph = UIAlertAction(title: "Kilometers per Hour", style: .default) { action in
            UserDefaults.standard.set("kph", forKey: "speedUnit")
            self.speedLabel.text = "Kilometers per Hour"
        }
        let mph = UIAlertAction(title: "Miles per Hour", style: .default) { action in
            UserDefaults.standard.set("mph", forKey: "speedUnit")
            self.speedLabel.text = "Miles per Hour"
        }
        let mps = UIAlertAction(title: "Meters per Second", style: .default) { action in
            UserDefaults.standard.set("mps", forKey: "speedUnit")
            self.speedLabel.text = "Meters per Second"
        }
        alert.addAction(kph)
        alert.addAction(mph)
        alert.addAction(mps)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // The current device is an iPad
            if let popup = alert.popoverPresentationController {
                   popup.sourceView = self.view
                   popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Change shot direction
    @IBAction func changeShotDirection(_ sender: Any) {
        //shot direction is a string data type.
        if self.directionLabel.text == "Left to Right"{
            //change to right to left
            UserDefaults.standard.set("rightToLeft", forKey: "shotDirection")
            self.directionLabel.text = "Right to Left"
        }else{
            //change to left to right
            UserDefaults.standard.set("leftToRight", forKey: "shotDirection")
            self.directionLabel.text = "Left to Right"
        }
        
    }
    //MARK: Haptic Feedback Changing
    @IBAction func changeHapticFeedback(_ sender: Any) {
        //haptic feedback is a boolean data type. true = on, false = off
        
        
        
        if self.hapticFeedbackLabel.text == "On"{
            UserDefaults.standard.set(false, forKey: "hapticFeedback")
            self.hapticFeedbackLabel.text = "Off"
        }else{
            UserDefaults.standard.set(true, forKey: "hapticFeedback")
            self.hapticFeedbackLabel.text = "On"
        }
        
    }
    
    @IBAction func changingModelVersion(_ sender: Any) {
        if self.modelVersionLabel.text == "Basic: Black Pucks"{
            let alert = UIAlertController(title: "Use Advanced Model?", message: "Would you like to use the advanced pink puck model? Note that HockeyRadar pink pucks are required, as this model is trained to detect pink pucks only. For information about HockeyRadar pink pucks, visit the shop.", preferredStyle: .alert)
            let proceed = UIAlertAction(title: "Proceed", style: .default) { action in
                UserDefaults.standard.set("Advanced", forKey: "modelVersion")
                self.modelVersionLabel.text = "Advanced: Pink Pucks"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(proceed)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }else{
            let alert = UIAlertController(title: "Revert to Basic Model?", message: "Would you like to use the basic black puck model? Only black pucks may be used for this model, and accuracy detection will be unavailable.", preferredStyle: .alert)
            let proceed = UIAlertAction(title: "Proceed", style: .default) { action in
                UserDefaults.standard.set("Basic", forKey: "modelVersion")
                self.modelVersionLabel.text = "Basic: Black Pucks"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(proceed)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
    
    
    
    @IBAction func subscriptionInfoTapped(_ sender: Any) {
        let message: String = """
        The free Basic Plan includes features such as the black puck model, the pink puck model, shot speed tracking, shot speed announcement, localized shot training (announces locations to shoot, customizable), and more.
        Subscribing to the Pro Plan adds more features such as session analysis and history tracking: average shot speed, shots taken, and visualizing accuracy on a visual for each session. You also unlock an ad free experience. Visit the shop screen for more information, to subscribe, or cancel a subscription.
        """
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
    }
    


    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
