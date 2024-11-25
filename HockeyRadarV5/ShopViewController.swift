//
//  ShopViewController.swift
//  HockeyRadarV5
//
//  Created by Aghajanov Alex on 2024-06-11.
//

import UIKit

class ShopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func advancedTrainingTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Information", message: "Advanced training includes accuracy tracking (Pink Pucks required, seperate purchase), progress tracking (view details of each session, such as average speed, date and other relevant info), and future experimental features. Would you like to continue with the subscription purchase?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Continue", style: .default) { action in
            print("buy subscription")
        }
        let viewDocument = UIAlertAction(title: "View More Info", style: .default) { action in
            if let url = URL(string: "https://docs.google.com/document/d/1AXG5JSlfZcWOSzpTAxRJbGy1u8-sdD2F8leR6M856WA/edit?usp=sharing") {
                UIApplication.shared.open(url)
            }
        }
        let copyEmail = UIAlertAction(title: "Copy Support Email To Clipboard", style: .default) { action in
            let pasteboard = UIPasteboard.general
            pasteboard.string = "hockeyradarapp@gmail.com"
        }
        let cancel = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(viewDocument)
        alert.addAction(copyEmail)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    
    @IBAction func orderPucks(_ sender: Any) {
        let message = 
        """
        Order HockeyRadar specialized pink pucks to step up your game and use the accuracy tracking feature! Note that the pink puck detection has been trained with HockeyRadar pucks specifically, which have specific markings and color shades for the puck detection model to perform best. Third party pink pucks do not guarantee functionality.
        Here is the pricing for pucks:
        5 for 15 CAD
        10 for 25 CAD
        25 for 50 CAD
        All prices are subject to 5% GST and relevant shipping fees. Contact support to place an order or ask additional questions.
        """
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let copySupportEmail = UIAlertAction(title: "Copy Support Email To Clipboard", style: .default) { action in
            let pasteboard = UIPasteboard.general
            pasteboard.string = "hockeyradarapp@gmail.com"
        }
        let cancel = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        alert.addAction(copySupportEmail)
        alert.addAction(cancel)
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
