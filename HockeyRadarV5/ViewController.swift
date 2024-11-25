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
import AVFoundation



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: Variables
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    let session = AVCaptureSession()
    var videoDataOutput = AVCaptureVideoDataOutput()
    var audioDataOutput = AVCaptureAudioDataOutput()
    var puckDetectionRequest: VNCoreMLRequest!
    
    var hapticFeedback = false
    
    var numberOfShots = 0
    
    var pathLayer = CAShapeLayer()
    
    var lineLengths: [Float] = []
    var personToNetPixels : Float!
    var personToCameraPixels: Float!
    
    var fetchResultController: NSFetchedResultsController<CalibrationInfo>!
    var fetchResultController2: NSFetchedResultsController<SettingsInfo>!
    var fetchResultController3: NSFetchedResultsController<Targets>!
    var fetchResultController4: NSFetchedResultsController<Sessions>!

    
    var currentDate: Date!
    
    var puckPixelArray1: [Float] = []
    
    var player: AVAudioPlayer?
    
    var allPucksInPreviousFrame: [VNDetectedObjectObservation] = []
    var currentShot: [VNDetectedObjectObservation] = []

    var fetchedUnit = ""
    var shotDirection = true
    
    var personToNetInches: Int16!
    var personToCameraInches: Int16!
    var detectedNet: Int = 0
    
    var net: VNDetectedObjectObservation!

    var shotSpeeds: [Float] = []
    
    var accuracyTrigger = false
    
    var date: Date!
    var date2: Date!
    
    var fetchedTargets: [String] = []
    
    var currentCGImage: CGImage!

    var currentTarget: String!
    
    var shotsTaken: [(Float, Float, Int16, String, String, Date, Bool)] = []
    
    var missedFramesInARow: Int = 0
    var missedFramesInTheShot: Int = 0
    
    
    
    
    
    @IBOutlet weak var editTargetsButton: UIButton!
    @IBOutlet var pucksLabel: UILabel!
    @IBOutlet var netsLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!{
        didSet
        {
            exitButton.backgroundColor = .red
            exitButton.tintColor = .white
            exitButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var accuracySwitch: UISwitch!{
        didSet
        {
            accuracySwitch.onTintColor = .blue
        }
    }
    @IBOutlet weak var pauseButton: UIButton!{
        didSet
        {
            pauseButton.isHidden = true
        }
    }
    
    
    

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pucksLabel.isHidden = true
        netsLabel.isHidden = true
        self.currentDate = Date()
        fetchCalibration()
        fetchSettings()
        
        initializeCaptureSession()

    }
    
    //MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            // Create Vision request based on CoreML model
            let model = try VNCoreMLModel(for: ModelV26_Iteration_2090(configuration: MLModelConfiguration()).model)
            puckDetectionRequest = VNCoreMLRequest(model: model)
            // Since board is close to the side of a landscape image,
            // we need to set crop and scale option to scaleFit.
            // By default vision request will run on centerCrop.
            puckDetectionRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            let alert = UIAlertController(title: "Vision Error", message: "Vision could not be prepared", preferredStyle: .alert)
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
        }
    }
    
    //MARK: Start/Stop Session
    
    @IBAction func startSession(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start"{
            let alert = UIAlertController(title: "Volume", message: "Ensure the device volume is set to max, or is connected to a speaker or headphones, in order to be able to hear shooting targets and your shot speed.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Proceed", style: .default) { action in
                print("started detecting")
                self.accuracySwitch.isUserInteractionEnabled = false
                self.exitButton.isHidden = true
                self.editTargetsButton.isHidden = true
                sender.setTitle("Stop", for: .normal)
                self.pucksLabel.isHidden = false
                self.netsLabel.isHidden = false
                self.pauseButton.isHidden = false
                //fetch locations to shoot at
                if let target = self.currentTarget{
                    self.playSound(sound: self.currentTarget)
                }
                self.fetchTargets()
                
            }
            let cancel = UIAlertAction(title: "Go Back", style: .cancel)
            alert.addAction(ok)
            alert.addAction(cancel)
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
            
            
        }else{
            self.accuracySwitch.isUserInteractionEnabled = true
            pucksLabel.isHidden = true
            netsLabel.isHidden = true
            self.pauseButton.isHidden = true

            print("stopped detecting")
            
            if self.shotsTaken.count > 0
            {
                //.2 is the speeds for the tuple, get the average
                var allSpeedsAdded: Int16 = 0
                
                var i = 0
                while i < self.shotsTaken.count
                {
                    allSpeedsAdded += self.shotsTaken[i].2
                    i += 1
                }
                
                let averageSpeed = Int(allSpeedsAdded) / self.shotsTaken.count
                self.playSound(sound: "AverageSpeed")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    self.playSound(sound: "\(averageSpeed)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        self.playSound(sound: "\(self.fetchedUnit)")
                    }
                }
                
                let uuid = UUID()
                
                // save session first to re-use the id in saving the shots
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let info = Sessions(context: context)
                    info.averageSpeed = Int16(averageSpeed)
                    info.date = self.currentDate
                    info.unit = self.fetchedUnit
                    info.uuid = uuid
                    info.numberOfShots = Int16(self.shotsTaken.count)
                    var targets = ""
                    for target in fetchedTargets {
                        if fetchedTargets.last != target{
                            targets += "\(target),"
                        }
                        else
                        {
                            targets += target
                        }
                        
                    }
                    info.targets = targets
                    
                    
                    appDelegate.saveContext()
                }
                
                
                //save all of the shots,
                
                var savedShots = 0
                for shot in self.shotsTaken
                {
                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                        let context = appDelegate.persistentContainer.viewContext
                        let info = Shots(context: context)
                        info.shotX = shot.0
                        info.shotY = shot.1
                        info.speed = shot.2
                        info.target = shot.3
                        info.unit = shot.4
                        info.sessionUUID = uuid
                        
                        
                        savedShots += 1
                        appDelegate.saveContext()
                    }
                }
                print("saved \(savedShots)")
            }else
            {
                print("nothing was saved")
            }
            
            
            self.exitButton.isHidden = false
            self.editTargetsButton.isHidden = false
            
            sender.setTitle("Start", for: .normal)
        }
    }
    
    //MARK: Exit Tapped
    
    @IBAction func exitTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: AccuracySwitch
    
    @IBAction func accuracySwitch(_ sender: UISwitch) {
        if sender.isOn
        {
            if UserDefaults.standard.string(forKey: "modelVersion") == "Basic"{
                let alert = UIAlertController(title: "Model Version", message: "To use accuracy tracking, the pink pucks model must be used. Change this in settings.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }else{
                editTargetsButton.isHidden = false
            }
        }
        else
        {
            editTargetsButton.isHidden = true
        }
    }
    
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        if self.pauseButton.titleLabel?.text == "Pause"{
            self.pauseButton.setTitle("Resume", for: .normal)
        }else{
            self.pauseButton.setTitle("Pause", for: .normal)
        }
        
        
    }
    
    
    
//MARK: Capture Output
    // AVCaptureVideoDataOutputSampleBufferDelegate callback.
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        //check if recording mode is on
        DispatchQueue.main.async {
            if self.recordButton.titleLabel?.text == "Stop"
            {
                
                //check if paused
                if self.pauseButton.titleLabel?.text == "Pause"{
                    //check if accuracy mode is on
                    if self.accuracySwitch.isOn{
                        //do the random location generation
                        if self.accuracyTrigger == false{
                            
                            let randomNum = Int.random(in: 0..<self.fetchedTargets.count)
                            
                            if self.date2 == nil
                            {
                                self.date2 = Date()
                            }
                            let timePassed = self.date2.timeIntervalSinceNow
                            
                            if timePassed < -2
                            {
                                self.accuracyTrigger = true
                                self.date2 = Date()
                                self.currentTarget = self.fetchedTargets[randomNum]
                                self.playSound(sound: self.fetchedTargets[randomNum])
                            }
                        }
                    }
                    
                    
                    
                    // MARK: Process the image
                    do {
                        
                        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
                        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
                            print("cannot make pixelbuffer for image conversion")
                            return
                        }
                        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
                        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
                        let width = CVPixelBufferGetWidth(pixelBuffer)
                        let height = CVPixelBufferGetHeight(pixelBuffer)
                        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
                        let colorSpace = CGColorSpaceCreateDeviceRGB()
                        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
                        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else{
                            print("cannot make context for image conversion")
                            return
                        }
                        guard let cgImage = context.makeImage() else{
                            print("cannot make cgimage for image conversion")
                            return
                        }
                        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
                        

                        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                        try? handler.perform([self.puckDetectionRequest])
                        

                        guard let _ = self.puckDetectionRequest.results as? [VNDetectedObjectObservation] else{
                            print("Could not convert detected pucks")
                            return
                        }
                        
                        
                        //MARK: Pucks vs nets
                        var pucks: [VNDetectedObjectObservation] = []
                        var nets: [VNDetectedObjectObservation] = []
                        
                        
                        
                        let model = try VNCoreMLModel(for: ModelV26_Iteration_2090(configuration: MLModelConfiguration()).model)
                        let objectRecognition = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                            DispatchQueue.main.async{
                                // perform all the UI updates on the main queue
                                
                                if let error = error{
                                    print(error.localizedDescription)
                                }
                                if let results = request.results {
                                    if results.count > 0
                                    {
                                        for observation in results where observation is VNRecognizedObjectObservation {
                                            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                                                continue
                                            }
                                            // Select only the label with the highest confidence.
                                            let topLabelObservation = objectObservation.labels[0].identifier
                                            if topLabelObservation == "puck"
                                            {
                                                //this one is a puck
                                                
                                                //if there are no pucks, add one to the current shot array
                                                pucks.append(objectObservation)
                                            }
                                            else
                                            {
                                                //this one is a net
                                                nets.append(objectObservation)
                                                self.detectedNet = 0
                                            }
                                        }
                                        
                                    }
                                    if nets.count == 0
                                    {
                                        self.detectedNet += 1
                                    }
                                    else if nets.count == 1
                                    {
                                        self.date = Date()
                                        self.net = nets[0]
                                        
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.pucksLabel.text = "Pucks: \(pucks.count)"
                                        self.netsLabel.text = "Nets: \(nets.count)"
                                    }
                                    
                                    
                                    if self.detectedNet > 1
                                    {
                                        if self.date == nil
                                        {
                                            self.date = Date()
                                        }
                                        let timePassed = self.date.timeIntervalSinceNow
                                        
                                        if timePassed < -3
                                        {
                                            self.date = Date()
                                            self.playSound(sound: "nonets")
                                        }
                                    }
                                    
                                    
                                    // check if there has been a saved since starting session. if there have been none,
                                    // dont look for shots yet. net is needed to be able to calculate speed
                                    
                                    if self.net != nil
                                    {
                                        //check if any pucks were detected, otherwise do nothing
                                        if pucks.isEmpty == false{
                                            
                                            //check if this is the first frame with pucks. if it is, then just assign them to the previous frame so we can compare them next frame.
                                            if self.allPucksInPreviousFrame.isEmpty
                                            {
                                                self.allPucksInPreviousFrame = pucks
                                            }
                                            else
                                            {
                                                //there were previously pucks in the frame. check the current pucks to find the one that is moving.
                                                //assign new pucks to previous frame to use next time, and save the old ones to use now.
                                                let pucksInPreviousFrame = self.allPucksInPreviousFrame
                                                self.allPucksInPreviousFrame = pucks
                                                
                                                var notMatchedOldPucks = pucksInPreviousFrame
                                                var notMatchedNewPucks = pucks
                                                
                                                var oldPucksToBeRemoved: [Int] = []
                                                var newPucksToBeRemoved: [Int] = []
                                                
                                                
                                                //loop through every current puck
                                                var currentPuck = 0
                                                for puck in pucks
                                                {
                                                    
                                                    //loop through previous pucks to find a match
                                                    var currentOldPuck = 0
                                                    for previousPuck in pucksInPreviousFrame
                                                    {
                                                        //check if x and y coordinates are the same. if they are then its the same puck
                                                        let screenHeight = UIScreen.main.bounds.size.height
                                                        let screenWidth = UIScreen.main.bounds.size.width
                                                        
                                                        let currentPuckX = puck.boundingBox.midX * screenWidth
                                                        let previousPuckX = previousPuck.boundingBox.midX * screenWidth
                                                        
                                                        let currentPuckY = puck.boundingBox.midY * screenHeight
                                                        let previousPuckY = previousPuck.boundingBox.midY * screenHeight
                                                        
                                                        
                                                        
                                                        //check if the center is within 5 pixels. model is not perfect, so looking for reasonable proximity
                                                        //use absolute value, so that sign does not matter
                                                        if abs(previousPuckX - currentPuckX) < 10 && abs(previousPuckY - currentPuckY) < 5
                                                        {
                                                            //add their number to their arrays to be removed later, in decreasing order so other locations dont get messed up
                                                            if !oldPucksToBeRemoved.contains([currentOldPuck]){
                                                                oldPucksToBeRemoved.append(currentOldPuck)
                                                            }
                                                            
                                                            if !newPucksToBeRemoved.contains([currentPuck]){
                                                                newPucksToBeRemoved.append(currentPuck)
                                                            }
                                                            
                                                        
                                                        }
                                                        currentOldPuck += 1
                                                    }
                                                    currentPuck += 1
                                                }
                                                
                                                //sort the to be removed pucks in decreasing order, and remove them in decreasing order
                                                oldPucksToBeRemoved.sort(by: >)
                                                newPucksToBeRemoved.sort(by: >)
                                                
                                                
                                                var i = 0
                                                while i < oldPucksToBeRemoved.count{
                                                    notMatchedOldPucks.remove(at: oldPucksToBeRemoved[i])
                                                    i += 1
                                                }
                                                
                                                
                                                var j = 0
                                                while j < newPucksToBeRemoved.count{
                                                    notMatchedNewPucks.remove(at: newPucksToBeRemoved[j])
                                                    j += 1
                                                }
                                                
                                                
                                                //need to check which pucks were not matched. there has to be one or zero.
                                                //if there is zero pucks left not matched for both, then every puck was matched, and nothing happened
                                                //if there is one new puck, then ignore and move on, it will be handled in the next frame.
                                                
                                                
                                                if notMatchedNewPucks.count == 1 && notMatchedOldPucks.count == 1
                                                {
                                                    //if there is one new puck and one old puck, this is the puck that moved. check if it was going forward.
                                                    //then, add this to current shot array, so that at the end speed can be calculated
                                                    let oldPuckX = notMatchedOldPucks[0].boundingBox.midX * UIScreen.main.bounds.size.width
                                                    let newPuckX = notMatchedNewPucks[0].boundingBox.midX * UIScreen.main.bounds.size.width
                                                    if newPuckX - oldPuckX > 0
                                                    {
                                                        if self.currentShot.isEmpty
                                                        {
                                                            //add both, since it is the first time where movement was detected compared to a previous frame
                                                            
                                                            self.currentShot.append(notMatchedOldPucks[0])
                                                            self.currentShot.append(notMatchedNewPucks[0])
                                                            
                                                            //also add any missed frames that would have accumulated
                                                            self.missedFramesInTheShot += self.missedFramesInARow
                                                            self.missedFramesInARow = 0
                                                        }
                                                        else
                                                        {
                                                            //add new one only, since the previous one was already added
                                                            self.currentShot.append(notMatchedNewPucks[0])
                                                            
                                                            //adding missed frames that could have accumulated
                                                            self.missedFramesInTheShot += self.missedFramesInARow
                                                            self.missedFramesInARow = 0
                                                        }
                                                    }
                                                    
                                                }
                                                else
                                                {
                                                    //if a new puck cannot be added, check if pucks were already added. if they were then either the shot finished, or there is a gap and a puck was not detected.
                                                    
                                                    if self.currentShot.count > 1
                                                    {
                                                        //at least 2 puck points were detected
                                                        //it may still be mid shot and a puck was simply not detected. maybe next shot it will be detected. up to two undetected pucks are allowed in between.
                                                        
                                                        if self.missedFramesInARow < 3{
                                                            self.missedFramesInARow += 1
                                                            
                                                        }else{
                                                            //shot is done.
                                                            //we are not adding the most recent missed frames because this time the shot was actually done. the detection was not bad in this case.
                                                            
                                                            
                                                            //find difference in pixels, convert to distance, find speed
                                                            let numberOfFrames = self.currentShot.count + self.missedFramesInTheShot
                                                            let lastPuck = self.currentShot.last
                                                            let firstPuck = self.currentShot.first
                                                            let lastPuckX = lastPuck!.boundingBox.midX * UIScreen.main.bounds.size.width
                                                            let firstPuckX = firstPuck!.boundingBox.midX * UIScreen.main.bounds.size.width
                                                            
                                                            
                                                            let differenceInPixels = lastPuckX - firstPuckX
                                                            let decimal = differenceInPixels / 812
                                                            
                                                            //get middle of shot, convert it to a decimal, multiply be experimental numbers and get the multiplier for the shot. this is going to be fine tuned in the future.
                                                            let averageX = (lastPuckX + firstPuckX) / 2
                                                            let averageXDecimal = averageX / 812
                                                            let ratioToBeAdded = averageXDecimal * 1.23
                                                            let ratio = 0.6 + ratioToBeAdded
                                                            
                                                            //get locations of player and net
                                                            
                                                            let netX = self.net.boundingBox.midX * 812.0
                                                            
                                                            
                                                            
                                                            //assuming player is just outside the frame
                                                            let playerX = 0.0
                                                            
                                                            let distancePixels = netX - playerX
                                                            let widthDividedByDistance = 812.0 / distancePixels
                                                            
                                                            let personToNetInchesDouble = Double(self.personToNetInches)
                                                            let widthOfFrameInches = personToNetInchesDouble * widthDividedByDistance
                                                            let inchesTravelled = decimal * widthOfFrameInches
                                                            let metersTravelled = inchesTravelled * 0.0254
                                                            let framesDouble = Double(numberOfFrames)
                                                            let secondsPassed = framesDouble / 60.0
                                                            let metersPerSecond = metersTravelled / secondsPassed
                                                            let kilometersPerHour = metersPerSecond * 3.6
                                                            let ratioKilometersPerHour = kilometersPerHour * ratio
                                                            let kilometersPerHourRounded = Int16(ratioKilometersPerHour)
                                                            
                                                            
                                                            
                                                            if kilometersPerHourRounded > 0
                                                            {
                                                                self.accuracyTrigger = false
                                                                
                                                                //accuracy detection if the mode is on
                                                                if self.accuracySwitch.isOn{
                                                                    self.currentCGImage = cgImage
                                                                    let puckLocationResult = self.shotLocation()
                                                                    
                                                                    //no net detected, return and ignore
                                                                    if puckLocationResult == (9999,9999, false)
                                                                    {
                                                                        return
                                                                    }
                                                                    
                                                                    print(puckLocationResult)
                                                                    
                                                                    //save puck location result to an array, then at the end save all the elements of the array
                                                                    self.shotsTaken.append((puckLocationResult.0, puckLocationResult.1, kilometersPerHourRounded, self.currentTarget, self.fetchedUnit, self.currentDate, puckLocationResult.2))
                                                                    
                                                                }
                                                                else
                                                                {
                                                                    self.shotsTaken.append((10000, 10000, kilometersPerHourRounded, "none", self.fetchedUnit, self.currentDate, false))
                                                                }
                                                                
                                                                
                                                                if self.date2 == nil
                                                                {
                                                                    self.date2 = Date()
                                                                    if kilometersPerHourRounded < 201
                                                                    {
                                                                        self.playSound(sound: "\(kilometersPerHourRounded)")
                                                                    }
                                                                    else
                                                                    {
                                                                        self.playSound(sound: "Over 200")
                                                                    }
                                                                }
                                                                let timePassed = self.date2.timeIntervalSinceNow
                                                                
                                                                if timePassed < -2
                                                                {
                                                                    self.date2 = Date()
                                                                    if kilometersPerHourRounded < 201
                                                                    {
                                                                        self.playSound(sound: "\(kilometersPerHourRounded)")
                                                                    }
                                                                    else
                                                                    {
                                                                        self.playSound(sound: "Over 200")
                                                                    }
                                                                    
                                                                }
                                                                
                                                                
                                                            }
                                                            else
                                                            {
                                                                print("Negative speed for some reason: \(kilometersPerHourRounded)")
                                                            }
                                                            
                                                            //resetting values for the current shot
                                                            self.missedFramesInARow = 0
                                                            self.missedFramesInTheShot = 0
                                                            self.currentShot.removeAll()
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    else if self.currentShot.count == 1
                                                    {
                                                        print("not enough for detecting speed")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        })
                        
                        
                        var requests = [VNRequest]()
                        requests.append(self.puckDetectionRequest)
                        requests.append(objectRecognition)
                        try requestHandler.perform(requests)

                    } catch {
                        // Handle the error.
                        print("ERROR IN CAPTURE OUTPUT: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
    }
    
    
    
    //MARK: Other functions
    
    func playSound(sound: String){
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = self.player else { return }
            
            player.play()
            

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: Shot location
    func completionHandler(request: VNRequest, error: Error?) {
        // Process the results.
        
        if let results = request.results
        {
            if results.count > 0
            {
                print("\(results.count) trajectories")

            }
        }
        
    }
    
    
    //
    
    func shotLocation() -> (Float,Float, Bool){
        //first two integers are x and y, bool is if the target was hit
        
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        
        let netWidthInPixels = self.net.boundingBox.size.width * screenWidth
        let netHeightInPixels = self.net.boundingBox.size.height * screenHeight
        
        
        
        
//        print("net width: \(netWidthInPixels)")
//        print("net height: \(netHeightInPixels)")

              
        if let net = self.net{
            
                        
            
            
            let screenHeight = UIScreen.main.bounds.size.height
            let screenWidth = UIScreen.main.bounds.size.width
            
            

            
            if let lastPuck = self.currentShot.last
            {
                let puckMidX = lastPuck.boundingBox.midX * screenWidth
                let puckMidY = lastPuck.boundingBox.midY * screenHeight
                
                let netLeftX = self.net.boundingBox.minX * screenWidth
                let netTopY = self.net.boundingBox.minY * screenHeight
                let netRightX = self.net.boundingBox.maxX * screenWidth
                let netBottomY = self.net.boundingBox.maxY * screenHeight
                
                
                
                let netMidX = self.net.boundingBox.midX * screenWidth
                let netMidY = self.net.boundingBox.midY * screenHeight

    //            print("net mid x : \(netMidX)")
    //            print("net mid y : \(netMidY)")

                let netMidLayerYBottom = netBottomY - (0.33 * self.net.boundingBox.size.height * screenHeight)
                let netTopLayerYBottom = netTopY + (0.33 * self.net.boundingBox.size.height * screenHeight)
                
                //reference point for x will be the left post, increases moving right
                //reference point for y will be the crossbar, increases moving down
                
                let puckDistanceFromLeftPost = puckMidX - netLeftX
                
                //convert to the ratio for saving X
                
                let ratioX = puckDistanceFromLeftPost / netWidthInPixels
                print("puck x for saving int: \(ratioX)")
                
                let puckDistanceFromCrossbar = puckMidY - netTopY
                
                //convert to the ratio for saving Y
                
                //top
                let image = UIImage(named: "dot")
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIView.ContentMode.scaleAspectFit
                imageView.frame.size.width = 30
                imageView.frame.size.height = 30
                
                imageView.center.x = puckMidX
                imageView.center.y = puckMidY
                
                self.view.addSubview(imageView)
                
                
                
                
                let ratioY = puckDistanceFromCrossbar / netHeightInPixels
                print("puckMidY: \(puckMidY). net top y: \(netTopY)")
                print("puck distance from crossbar: \(puckDistanceFromCrossbar)")
                print("net height in pixels: \(netHeightInPixels)")
                print("ratio y: \(ratioY)")

                
                //checking if it was in the target
                //IMPORTANT: ACCURACY IS NOT DISPLAYED TO THE USER YET, THIS WILL BE FULLY ADDED IN A NEW UPDATE.
                
                if self.currentTarget == "TL"
                {
                    //check if x is correct
                    if puckMidX >= netLeftX && puckMidX < netMidX
                    {
                        //check if y is correct
                        if puckMidY > netTopLayerYBottom && puckMidY < netTopY
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                }
                else if self.currentTarget == "ML"
                {
                    //check if x is correct
                    if puckMidX >= netLeftX && puckMidX < netMidX
                    {
                        //check if y is correct
                        if puckMidY >= netMidLayerYBottom && puckMidY < netTopLayerYBottom
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                    
                }
                else if self.currentTarget == "BL"
                {
                    //check if x is correct
                    if puckMidX >= netLeftX && puckMidX < netMidX
                    {
                        //check if y is correct
                        if puckMidY >= netBottomY && puckMidY < netMidLayerYBottom
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                    
                }
                else if self.currentTarget == "TR"
                {
                    //check if x is correct
                    if puckMidX >= netMidX && puckMidX < netRightX
                    {
                        //check if y is correct
                        if puckMidY >= netTopLayerYBottom && puckMidY < netTopY
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                    
                }
                else if self.currentTarget == "MR"
                {
                    //check if x is correct
                    if puckMidX >= netMidX && puckMidX < netRightX
                    {
                        //check if y is correct
                        if puckMidY >= netMidLayerYBottom && puckMidY < netTopLayerYBottom
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                    
                }
                else
                {
                    //check if x is correct
                    if puckMidX >= netMidX && puckMidX < netRightX
                    {
                        //check if y is correct
                        if puckMidY >= netBottomY && puckMidY < netMidLayerYBottom
                        {
                            //accurate shot
                            return (Float(ratioX), Float(ratioY), true)
                        }
                        else
                        {
                            //innacurate
                            return (Float(ratioX), Float(ratioY), false)
                        }
                    }
                    else
                    {
                        //x is wrong, return innacurate
                        return (Float(ratioX), Float(ratioY), false)
                    }
                    
                    
                }
                
                
            }
            
            
            
        }
        return (9999,9999, false)
        
        
    }
    
    
    
    //MARK: Fetch Calibration
    
    func fetchCalibration(){
        let fetchRequest: NSFetchRequest<CalibrationInfo> = CalibrationInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "personToNet", ascending: true)
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
                        let alert = UIAlertController(title: "Calibration", message: "There are no calibration settings saved. Please calibrate the camera before starting.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel) { action in
                            self.dismiss(animated: true)
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
                    else if fetchedObjects.count > 1
                    {
                        //multiple calibrations found, delete all of them and force new calibration
                        for object in fetchedObjects {
                            context.delete(object)
                            print("deleted one")
                        }
                        let alert = UIAlertController(title: "Calibration", message: "There was a problem with the calibration settings. A new calibration is needed before starting.", preferredStyle: .alert)
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
                    else
                    {
                        //do whateer is needed with the calibration
                        self.personToNetInches = fetchedObjects[0].personToNet
                        self.personToCameraInches = fetchedObjects[0].personToCamera
                    }
                    
                    
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    
    //MARK: Fetch Settings
    
    func fetchSettings(){
        
        if UserDefaults.standard.string(forKey: "modelVersion") == "Basic" {
            accuracySwitch.isOn = false
            editTargetsButton.isHidden = true
        }
        self.fetchedUnit = UserDefaults.standard.string(forKey: "speedUnit") ?? "kph"
        self.shotDirection = UserDefaults.standard.bool(forKey: "shotDirection") ?? true
        self.hapticFeedback = UserDefaults.standard.bool(forKey: "hapticFeedback")?? true
        
        
        /*
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
                            info.hapticFeedback = true
                            info.shotDirection = true
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
                            info.hapticFeedback = true
                            info.shotDirection = true
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
         */
    }
    
    //MARK: Fetch targets
    
    func fetchTargets(){
        let fetchRequest: NSFetchRequest<Targets> = Targets.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "target", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController3 = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController3.delegate = self
            do {
                try fetchResultController3.performFetch()
                
                if let fetchedObjects = fetchResultController3.fetchedObjects{
                    if fetchedObjects.count == 0
                    {
                        //save all six as targets and set those as the fetched ones
                        
                        let context = appDelegate.persistentContainer.viewContext
                        let targetsToSave = ["TL", "ML", "BL", "TR", "MR", "BR"]
                        
                        for target in targetsToSave{
                            let info = Targets(context: context)
                            info.target = target
                            appDelegate.saveContext()
                        }
                        
                        
                        
                        
                        self.fetchedTargets = targetsToSave
                        
                        
                        
                    }
                    else if fetchedObjects.count > 6
                    {
                        //TODO: messed up stuff, handle this somehow
                        //just delete all of them and save all six
                        print("OVER SIX TARGETS FETCHED")
                    }
                    else
                    {
                        
                        for fetchedObject in fetchedObjects {
                            if fetchedObject.target! == "TL"
                            {
                                self.fetchedTargets.append("TL")
                            }
                            else if fetchedObject.target! == "ML"
                            {
                                self.fetchedTargets.append("ML")
                            }
                            else if fetchedObject.target! == "BL"
                            {
                                self.fetchedTargets.append("BL")
                            }
                            else if fetchedObject.target! == "TR"
                            {
                                self.fetchedTargets.append("TR")
                            }
                            else if fetchedObject.target! == "MR"
                            {
                                self.fetchedTargets.append("MR")
                            }
                            else
                            {
                                self.fetchedTargets.append("BR")
                            }
                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }

   
    
    func initializeCaptureSession(){
        session.sessionPreset = .hd1920x1080
        camera = AVCaptureDevice.default(for: .video)
        microphone = AVCaptureDevice.default(for: .audio)
        print("began camera recording")
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

