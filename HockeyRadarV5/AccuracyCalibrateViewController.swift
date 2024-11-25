//
//  AccuracyCalibrateViewController.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-05-31.
//

import UIKit
import AVFoundation
import ImageIO
import Vision
import AVFoundation
import CoreData

class AccuracyCalibrateViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.backgroundColor = .blue
            saveButton.tintColor = .white
            saveButton.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var rightStackView: UIStackView!
    
    @IBOutlet weak var leftStackView: UIStackView!
    
    @IBOutlet weak var topLeft: UIButton!{
        didSet{
            topLeft.backgroundColor = .red
            topLeft.contentHorizontalAlignment = .center

        }
    }
    @IBOutlet weak var midLeft: UIButton!{
        didSet{
            midLeft.backgroundColor = .red
            midLeft.contentHorizontalAlignment = .center

        }
    }
    @IBOutlet weak var bottomLeft: UIButton!{
        didSet{
            bottomLeft.backgroundColor = .red
            bottomLeft.contentHorizontalAlignment = .center
        }
    }
    @IBOutlet weak var topRight: UIButton!{
        didSet{
            topRight.backgroundColor = .red
            topRight.contentHorizontalAlignment = .center
        }
    }
    @IBOutlet weak var midRight: UIButton!{
        didSet{
            midRight.backgroundColor = .red
            midRight.contentHorizontalAlignment = .center
        }
    }
    @IBOutlet weak var bottomRight: UIButton!{
        didSet{
            bottomRight.backgroundColor = .red
            bottomRight.contentHorizontalAlignment = .center
        }
    }
    
    
    var fetchResultController: NSFetchedResultsController<Targets>!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTargets()
        
    }
    
    func fetchTargets(){
        let fetchRequest: NSFetchRequest<Targets> = Targets.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "target", ascending: true)
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
                        //turn everything green
                        self.topLeft.backgroundColor = .green
                        self.midLeft.backgroundColor = .green
                        self.bottomLeft.backgroundColor = .green
                        self.topRight.backgroundColor = .green
                        self.midRight.backgroundColor = .green
                        self.bottomRight.backgroundColor = .green
                    }
                    else if fetchedObjects.count > 6
                    {
                        //TODO: messed up stuff, handle this somehow
                        print("OVER SIX")
                    }
                    else
                    {
                        for fetchedObject in fetchedObjects {
                            print("\(fetchedObject.target!) just got fetched.")
                            if fetchedObject.target! == "TL"
                            {
                                self.topLeft.backgroundColor = .green
                            }
                            else if fetchedObject.target! == "ML"
                            {
                                self.midLeft.backgroundColor = .green
                            }
                            else if fetchedObject.target! == "BL"
                            {
                                self.bottomLeft.backgroundColor = .green
                            }
                            else if fetchedObject.target! == "TR"
                            {
                                self.topRight.backgroundColor = .green
                            }
                            else if fetchedObject.target! == "MR"
                            {
                                self.midRight.backgroundColor = .green
                            }
                            else
                            {
                                self.bottomRight.backgroundColor = .green
                            }
                        }
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    
    @IBAction func saveTapped(_ sender: Any) {
        //make sure at least 2 targets are selected
        var numberGreen: Int = 0
        var needToBeSaved: [String] = []
        if topLeft.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("TL")
        }
        if midLeft.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("ML")
        }
        if bottomLeft.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("BL")
        }
        if topRight.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("TR")
        }
        if midRight.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("MR")
        }
        if bottomRight.backgroundColor == .green
        {
            numberGreen += 1
            needToBeSaved.append("BR")
        }
        if numberGreen < 1
        {
            // no targets selected. prompt user to pick more targets.
            let alert = UIAlertController(title: "Pick more targets", message: "Please pick at least 1 target to practice with.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(ok)
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
        
        
        //delete everything previously
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Targets")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                try context.execute(deleteRequest)
                print("Deleted previous targets")
            }
        } catch let error as NSError {
            // TODO: handle the error
            print("error: \(error.localizedDescription)")
            return
        }
        
        //save to database, and provide alert then dismiss.
        var itemsToSave: Int = 0
        for target in needToBeSaved
        {
            //save the target
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let info = Targets(context: context)
                info.target = target
                itemsToSave += 1
                print("Saved: \(target)")
                appDelegate.saveContext()
            }
        }
        print("\(itemsToSave) targets saved")
        let alert = UIAlertController(title: "Saved", message: "Settings have been updated successfully.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
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
    
    @IBAction func topLeftTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
    }
    
    @IBAction func midLeftTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
    }
    
    @IBAction func bottomLeftTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
    }
    
    @IBAction func topRightTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
    }
    
    @IBAction func midRightTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
    }
    
    @IBAction func bottomRightTapped(_ sender: UIButton) {
        if sender.backgroundColor == .red
        {
            sender.backgroundColor = .green
        }
        else
        {
            sender.backgroundColor = .red
        }
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
