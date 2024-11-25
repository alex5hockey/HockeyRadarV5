//
//  SessionTableViewController.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-07-18.
//

import UIKit
import CoreData

class SessionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchResultController: NSFetchedResultsController<Sessions>!
    var fetchResultController2: NSFetchedResultsController<Shots>!
    var fetchResultController3: NSFetchedResultsController<Shots>!

        
    
    var sessions: [Sessions] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchSessions()
        
        let shots = self.fetchShots2()
        print("Shots: \(shots)")
        
        self.navigationController?.navigationBar.tintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "session", for: indexPath) as! SessionsTableViewCell
        // Configure the cell...

        cell.shotsCount.text = "Shots: \(self.sessions[indexPath.row].numberOfShots)"
        
        let date = sessions[indexPath.row].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let stringDate = dateFormatter.string(from: date!)
        let timeDate = timeFormatter.string(from: date!)
        
        cell.date.text = "\(stringDate)     \(timeDate)"

        

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        haptic()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        haptic()
        self.dismiss(animated: true)
    }
    
    
    
    
    
    
    //MARK: Fetch Sessions
    
    func fetchSessions(){
        let fetchRequest: NSFetchRequest<Sessions> = Sessions.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                
                if let fetchedObjects = fetchResultController.fetchedObjects{
                    self.sessions = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    //MARK: Fetch shots
    
    func fetchShots(session: Sessions) -> [Shots]{
        var shots: [Shots] = []
        
        let fetchRequest: NSFetchRequest<Shots> = Shots.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "unit", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController2 = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController2.delegate = self
            do {
                try fetchResultController2.performFetch()
                if let fetchedObjects = fetchResultController2.fetchedObjects{
                    for shot in fetchedObjects{
                        if shot.sessionUUID == session.uuid
                        {
                            shots.append(shot)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        return shots
    }
    
    
    func fetchShots2() -> Int{
        let fetchRequest: NSFetchRequest<Shots> = Shots.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "unit", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController3 = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController3.delegate = self
            do {
                try fetchResultController3.performFetch()
                if let fetchedObjects = fetchResultController3.fetchedObjects{
                    return fetchedObjects.count
                }
            } catch {
                print(error)
            }
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the database
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let session = self.sessions[indexPath.row]
                context.delete(session)
                
                //match the shots with that session
                
                let shots: [Shots] = fetchShots(session: session)
                for shot in shots
                {
                    context.delete(shot)
                }
                
                appDelegate.saveContext()
                print("deleted sessions and shots")
                self.sessions.remove(at: indexPath.row)
                
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
            
            
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "details"
        {
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationViewController = segue.destination as! DetailsViewController
                destinationViewController.session = self.sessions[indexPath.row]
            }
            
        }
    }
    

}
