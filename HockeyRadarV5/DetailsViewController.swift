//
//  DetailsViewController.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-07-18.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var targetsLabel: UILabel!
    

    var session: Sessions!
    var fetchedUnit = ""
    var shots: [Shots] = []
    
    @IBOutlet weak var netImage: UIImageView!
    
    var fetchResultController: NSFetchedResultsController<Shots>!
    var fetchResultController2: NSFetchedResultsController<SettingsInfo>!

    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        fetchShots()
        fetchUnit()
        presentEverything()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        haptic()
    }
    
    
    //MARK: Shot fetch
    
    func fetchShots(){
        let fetchRequest: NSFetchRequest<Shots> = Shots.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "unit", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects{
                    for shot in fetchedObjects{
                        if shot.sessionUUID == self.session.uuid
                        {
                            self.shots.append(shot)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    //MARK: Unit fetch
    func fetchUnit(){
        //if multiple or no settings fetched, need to reset settings and delete all
        let fetchRequest: NSFetchRequest<SettingsInfo> = SettingsInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "speedUnits", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController2 = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController2.delegate = self
            do {
                try fetchResultController2.performFetch()
                if let fetchedObjects = fetchResultController2.fetchedObjects{
                    //make sure 1 setting was there
                    if fetchedObjects.count == 0
                    {
                        
                        //if there are none, make a default settings for the user
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let info = SettingsInfo(context: context)
                            info.speedUnits = "kph"
                            appDelegate.saveContext()
                            self.fetchedUnit = "kph"
                        }
                    }
                    else if fetchedObjects.count > 1
                    {
                        //multiple settings, delete everything and make a new one
                        
                        //delete everything previously
                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SettingsInfo")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                let context = appDelegate.persistentContainer.viewContext
                                try context.execute(deleteRequest)
                                print("deleted")
                            }
                        } catch let error as NSError {
                            // TODO: handle the error
                            print("error: \(error.localizedDescription)")
                        }
                        //make default settings
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let info = SettingsInfo(context: context)
                            info.speedUnits = "kph"
                            appDelegate.saveContext()
                            self.fetchedUnit = "kph"
                        }
                    }
                    
                    else
                    {
                        //one setting was there
                        self.fetchedUnit = fetchedObjects[0].speedUnits!
                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    //MARK: Present Everything
    
    
    func presentEverything(){
        
        //units label
        if self.session.unit == self.fetchedUnit{
            self.speedLabel.text = "Average shot velocity in this session was \(self.session.averageSpeed) \(self.fetchedUnit)"
        }
        else
        {
            //change the saved unit to whatever the unit has selected now
            if self.session.unit == "kph"
            {
                if fetchedUnit == "mph"
                {
                    //kph to mph
                    let newSpeed = Int(Double(self.session.averageSpeed) * 0.621)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) mph"
                }
                else if fetchedUnit == "mps"
                {
                    //kph to mps
                    let newSpeed = Int(Double(self.session.averageSpeed) / 3.6)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) mps"
                }
            }
            else if self.session.unit == "mph"
            {
                if fetchedUnit == "kph"
                {
                    //mph to kph
                    let newSpeed = Int(Double(self.session.averageSpeed) * 1.61)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) kph"
                }
                else if fetchedUnit == "mps"
                {
                    //mph to mps
                    let newSpeed = Int(Double(self.session.averageSpeed) * 0.447)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) mps"
                }
            }
            else if self.session.unit == "mps"
            {
                if fetchedUnit == "kph"
                {
                    //mps to kph
                    let newSpeed = Int(Double(self.session.averageSpeed) * 3.6)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) kph"
                }
                else if fetchedUnit == "mph"
                {
                    //kph to mph
                    let newSpeed = Int(Double(self.session.averageSpeed) / 1.61)
                    self.speedLabel.text = "Average shot velocity in this session was \(newSpeed) kph"
                }
            }
            
        }
        
        
        print("Shots for this type: \(shots.count)")
        
        //adding dots:
        
        if shots[0].shotX == 10000 && shots[0].shotY == 10000 && shots[0].accurate == false
        {
            //accuracy mode was off for the session
            self.targetsLabel.isHidden = true
            
        }
        else
        {
            
            for shot in self.shots
            {
                
                print("shot x ratio: \(shot.shotX)")
                print("shot y ratio: \(shot.shotY)")

                
                
                let shotX = Double(shot.shotX) * 240
                let shotY = Double(shot.shotY) * 160
                
                let image = UIImage(named: "dot")
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIView.ContentMode.scaleAspectFit
                imageView.frame.size.width = 10
                imageView.frame.size.height = 10
                
                let netLeftPost = self.netImage.center.x - 120
                let netTopPost = self.netImage.center.y - 80
                
                
                imageView.center.x = netLeftPost + shotX
                imageView.center.y = netTopPost + shotY
                
                print("object added at \(netLeftPost + shotX), \(netTopPost + shotY)")
                if imageView.center.x > netImage.center.x - 120 && imageView.center.x < netImage.center.x + 120 && imageView.center.y > netImage.center.y - 80 && imageView.center.y < netImage.center.y + 80
                {
                    self.view.addSubview(imageView)
                }
                
                
                
            }
            
                        
            
        }
        
        //date label
        let date = self.session.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let stringDate = dateFormatter.string(from: date!)
        self.dateLabel.text = stringDate
        
        //targets label
        
        if let targets = self.session.targets{
            targetsLabel.text = "Targets: \(targets)"

        }
       
    }
    
    
    
    
    
    @IBAction func infoTapped(_ sender: Any) {
        haptic()
        let alert = UIAlertController(title: "Help improve HockeyRadar!", message: "This app's puck detection is continuously being improved! If not already done, check out the setup guide to improve puck detection and yield better results. If this does not work, consider sending a video with you taking 5 shots in your setup to hockeyradarapp@gmail.com . I will add these videos to the AI that detects shots, and you can expect much better results in the next update. Happy shooting!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        let copyEmail = UIAlertAction(title: "Copy Email", style: .default) { action in
            UIPasteboard.general.string = "hockeyradarapp@gmail.com"
        }
        alert.addAction(ok)
        alert.addAction(copyEmail)
        self.present(alert, animated: true)
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
