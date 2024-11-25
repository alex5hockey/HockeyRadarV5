//
//  ViewController.swift
//  HockeyRadarV2
//
//  Created by Alex Aghajanov on 2022-10-17.
//

import UIKit
import AVFoundation
import ImageIO
import Vision
import CoreData

class CalibrationViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: Variables
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    let session = AVCaptureSession()
    var videoDataOutput = AVCaptureVideoDataOutput()
    var audioDataOutput = AVCaptureAudioDataOutput()

    var pathLayer = CAShapeLayer()

    var instructionIndex: Int = 0
    var instructions: [String] = ["Place the device as shown in the diagram, so it views the player and net. Ensure there is a 90 degree angle between the camera, player, and net.", "Measure the distances between the net and player, and camera and player, in inches. Provide the measurements below, in inches.", "After calibration, do not move the camera. If you do, recalibrate."]
    
    var fetchResultController: NSFetchedResultsController<CalibrationInfo>!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var diagram: UIImageView!
    @IBOutlet weak var personToNet: UITextField!
    @IBOutlet weak var personToCamera: UITextField!
    

    
    var personToCameraInt: Int16!
    var personToNetInt: Int16!
    
    
    
    

    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateData()
        
        
        initializeCaptureSession()
        
        
    }
    
    
    
    //MARK: IBAction Functions
    @IBAction func nextTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "Next"
        {
            //check if unreasonable numbers were inputted
            if instructionIndex == 1
            {
                if self.personToNet.text == "" || self.personToCamera.text == ""
                {
                    let alert = UIAlertController(title: "Missing Distance(s)", message: "Please ensure you have filled in the distances.", preferredStyle: .alert)
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
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                //check for stupidly big strings
                if self.personToNet.text!.count > 3 || self.personToCamera.text!.count > 3
                {
                    let alert = UIAlertController(title: "Distance(s) too large", message: "Try having your distances less than 300 inches, for accurate detection.", preferredStyle: .alert)
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
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                //check if number is over 300 or not
                self.personToNetInt = Int16(self.personToNet.text!)!
                self.personToCameraInt = Int16(self.personToCamera.text!)!
                if self.personToNetInt > 300 || self.personToCameraInt > 300
                {
                    let alert = UIAlertController(title: "Distance(s) too large", message: "Try having your distances less than 300 inches, for accurate detection.", preferredStyle: .alert)
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
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                
                
            }
            
            instructionIndex += 1
            self.instructionsLabel.text = instructions[instructionIndex]
            
            if instructionIndex == 1
            {
                self.backButton.alpha = 1.0
                self.backButton.isUserInteractionEnabled = true
                self.diagram.isHidden = true
                self.diagram.image = UIImage(named: "dinkydiagram")
                self.personToNet.isHidden = false
                self.personToCamera.isHidden = false
            }
            else if instructionIndex == 2
            {
                self.personToNet.isHidden = true
                self.personToCamera.isHidden = true
                self.diagram.isHidden = true

            }
            
            
            if instructionIndex == instructions.count - 1
            {
                self.nextButton.setTitle("Finish", for: .normal)
            }
            
        }
        else
        {
            //save info and dismiss
            self.saveInfo()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.instructionIndex -= 1
        instructionsLabel.text = instructions[instructionIndex]
        if instructionIndex == 0
        {
            self.backButton.alpha = 0.0
            self.backButton.isUserInteractionEnabled = false
            
            self.diagram.isHidden = false
            self.personToNet.isHidden = true
            self.personToCamera.isHidden = true
            
        }
        else if instructionIndex == 1
        {
            
            self.personToNet.isHidden = false
            self.personToCamera.isHidden = false
            
            
        }
        else if instructionIndex == 2
        {
            self.backButton.alpha = 1.0
            self.backButton.isUserInteractionEnabled = true
            self.diagram.isHidden = true
            self.personToNet.isHidden = false
            self.personToCamera.isHidden = false
        }
        
        
        if instructionIndex == instructions.count - 2
        {
            self.nextButton.setTitle("Next", for: .normal)
        }
        
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Would you like to cancel calibration?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { action in
            self.dismiss(animated: true, completion: nil)
        }
        let no = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yes)
        alert.addAction(no)
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
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: Functions
    func saveInfo(){
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
                    print("Current objects: \(fetchedObjects.count)")
                    
                    for object in fetchedObjects {
                        context.delete(object)
                        print("deleted one")
                    }
                }
            } catch {
                //TODO: handle the error
                print(error)
            }
        }
        
        //save current calibration
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            let info = CalibrationInfo(context: context)
            info.personToCamera = self.personToCameraInt
            info.personToNet = self.personToNetInt
            
            appDelegate.saveContext()
            print("saved")
        }
    }
    
    
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func populateData(){
        self.backButton.alpha = 0.0
        self.backButton.isUserInteractionEnabled = false
        self.diagram.isHidden = false
        self.diagram.image = UIImage(named: "dinkydiagram")
        self.personToNet.isHidden = true
        self.personToCamera.isHidden = true
        
        instructionsLabel.text = instructions[0]
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
   
    
    func initializeCaptureSession(){
        session.sessionPreset = .hd1920x1080
        camera = AVCaptureDevice.default(for: .video)
        microphone = AVCaptureDevice.default(for: .audio)
        
        do{
            session.beginConfiguration()
            
            //adding camera
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            if session.canAddInput(cameraCaptureInput){
                session.addInput(cameraCaptureInput)
            }
            
            
            //output
            let queue = DispatchQueue(label: "output")
            if session.canAddOutput(videoDataOutput) {
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                session.addOutput(videoDataOutput)
                
            }
            
            let captureConnection = videoDataOutput.connection(with: .video)
            // Always process the frames
            captureConnection?.isEnabled = true
            do {
                try camera!.lockForConfiguration()
                camera!.unlockForConfiguration()
            } catch {
                print(error)
            }
            
            session.commitConfiguration()
            
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraPreviewLayer?.videoGravity = .resizeAspectFill
            cameraPreviewLayer?.frame = view.bounds
            cameraPreviewLayer?.connection?.videoRotationAngle = 0
            
            view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            self.cameraPreviewLayer!.addSublayer(pathLayer)
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
  
        } catch {
            print(error.localizedDescription)
        }
    }

}

