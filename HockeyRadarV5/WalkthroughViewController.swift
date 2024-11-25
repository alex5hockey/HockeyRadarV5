//
//  WalkthroughViewController.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-05-30.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    @IBOutlet var infoLabel: UILabel! {
        didSet{
            infoLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var websiteButton: UIButton!{
        didSet{
            websiteButton.titleLabel?.textAlignment = .center

        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var image: UIImageView!
    
    
    var images: [String] = ["shootingandaccuracy","sticks", "nets", "backgrounds", ""]
    var info: [String] = ["With this app, improve your shot speed, accuracy, or both!", "Before starting, ensure you are using white tape. Black tape can interfere with puck detection, and your stick may be mistaken for a puck.", "Remove excessive puck marks or disruptive colors from the goal posts, or spray paint the posts red. This may interfere with net detection.", "Ensure the background does not have dark spots, and is a consistent light color. This may interfere with puck detection.", "For more tips to improve your setup, find more info here:"]
    var index = 0
    
    

    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.pageControl.numberOfPages = info.count
        self.pageControl.currentPage = 0
        previousButton.backgroundColor = .white
        previousButton.isUserInteractionEnabled = false
        infoLabel.text = info[index]
        if let image = UIImage(named: self.images[index]){
            self.image.image = image
        }
        
    }
    

    
    
    @IBAction func previousTapped(_ sender: Any) {
        haptic()
        index -= 1
        pageControl.currentPage -= 1
        infoLabel.text = info[index]
        nextButton.setTitle("Next", for: .normal)
        websiteButton.isHidden = true
        image.alpha = 1.0
        if index == 0
        {
            previousButton.backgroundColor = .white
            previousButton.isUserInteractionEnabled = false
        }
        if let image = UIImage(named: self.images[index]){
            self.image.image = image
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        haptic()
        if nextButton.titleLabel?.text == "Finish"
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        index += 1
        pageControl.currentPage += 1
        infoLabel.text = info[index]
        if let image = UIImage(named: self.images[index]){
            self.image.image = image
        }
        
        if index > 0
        {
            previousButton.backgroundColor = .systemBlue
            previousButton.isUserInteractionEnabled = true
        }
        if index == info.count - 1
        {
            websiteButton.isHidden = false
            nextButton.setTitle("Finish", for: .normal)
            image.alpha = 0.0
            
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://docs.google.com/document/d/1AXG5JSlfZcWOSzpTAxRJbGy1u8-sdD2F8leR6M856WA/edit?usp=sharing"){
            UIApplication.shared.open(url)
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
