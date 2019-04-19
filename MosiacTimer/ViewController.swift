//
//  ViewController.swift
//  MosiacTimer
//
//  Created by Sanjeev on 17/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit
import UserNotifications
import MKRingProgressView
import BottomPopup



class ViewController: UIViewController {
   
    var btnSelected = 0
    var atimer: Timer?
    var backTimer: Timer?
    let status = TimeStatusModel()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var ringProgressView: RingProgressView?
    @IBOutlet var settingBtn: UIButton!
    @IBOutlet var startStopBtn: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //setting notification tone to default if there is no user selection
        if status.audioTone == "nil"
        {
            status.audioTone = "Default"
        }
        
        // calling UI creation
        createBtn()
        
        // setting initial value to the timer to 5mins
        if status.targetTime == 0
        {
            status.targetTime = 300
        }
        btnSelected = status.targetTime
        
        // adding the start time to user defaults
        status.startTime = Date()
        
        //Starting the timer
        if atimer != nil
        {
            atimer?.invalidate()
        }
        atimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.startTimer), userInfo: nil, repeats: true)
        RunLoop.current.add((atimer ?? nil)!, forMode: RunLoop.Mode.tracking)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startStopBtnAction(sender: UIButton!) {
        if sender.titleLabel?.text == "STOP"
        {
            sender.setTitle("START",for: .normal)
            if atimer != nil
            {
                atimer?.invalidate()
            }
            if backTimer != nil
            {
                backTimer?.invalidate()
            }
            ringProgressView?.removeFromSuperview()
            covertTimeInterval(interval: TimeInterval(status.targetTime))
        
        }
        else
        {
            sender.setTitle("STOP",for: .normal)
            let buttons = self.view.subviews.compactMap { $0 as? UIButton }
            
            for button in buttons {
                if button.tag == status.targetTime
                {
                    buttonAction(sender: button)
                }
            }
        }
    }
    
    @IBAction func settingsBtnAction(_ sender: Any) {
        
        // setting page UI creation
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else { return }
        popupVC.height = self.view.frame.height - timeLabel.frame.height
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 1.0
        popupVC.dismissDuration = 1.0
        popupVC.shouldDismissInteractivelty = true
        present(popupVC, animated: true, completion: nil)
    }
    
    func createBtn() {
        let btnSize : Int = Int((self.view.frame.width-165)/3)
        var xvalue = 30
        var yvalue = Int(timeLabel.frame.origin.y + timeLabel.frame.height + 30)
        var button = UIButton();
        var btnLabel = UILabel();
        
        // creating 6 buttons in 2 columns with 3 buttons in a row
        for column in 0..<2{
            for row in 0..<3{
                button = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: btnSize , height: btnSize))
                button.backgroundColor = .clear
                switch column {
                // setting title to number of mins
                case 0:
                    
                    switch row {
                        
                    case 0:
                        button.setTitle("1",for: .normal)
                    case 1:
                        button.setTitle("5",for: .normal)
                    case 2:
                        button.setTitle("15",for: .normal)
                    default:
                        print("First number is 0, second number is not")
                        
                    }
                case 1:
                    switch row {
                        
                    case 0:
                        button.setTitle("30",for: .normal)
                    case 1:
                        button.setTitle("45",for: .normal)
                    case 2:
                        button.setTitle("60",for: .normal)
                    default:
                        print("First number is 0, second number is not")
                        
                    }
                    
                default:
                    
                    print("First number is not 0")
                    
                }
                
                var btnTag : Int = Int(button.currentTitle ?? "0") ?? 0
                
                button.layer.cornerRadius = 0.5 * button.bounds.size.width
                button.clipsToBounds = true
                button.layer.borderWidth = 4
               
                // setting tag to number of seconds to access it in button action
                button.tag = btnTag * 60
                
                button.layer.borderColor = UIColor.btnBorderColor.cgColor
                button.titleLabel?.font = UIFont(name:"HelveticaNeue", size: 30.0)
                button.setTitleColor(UIColor.btnTextColor, for: .normal)
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                self.view.addSubview(button)
                
                btnLabel = UILabel(frame: CGRect(x: Int(button.frame.origin.x + 20), y: yvalue - 20, width: btnSize - 40 , height: 6))
                btnLabel.tag = btnTag * 600
                
                //checking which button should selected when app is opened
                if btnTag == status.targetTime/60
                {
                    btnLabel.backgroundColor = .red
                    
                    ringProgressView = RingProgressView(frame: CGRect(x: xvalue-6, y: yvalue-6, width: btnSize+12, height: btnSize+12))
                    ringProgressView!.startColor = UIColor.labelColor
                    ringProgressView!.endColor = UIColor.labelColor
                    ringProgressView!.backgroundRingColor = .clear
                    ringProgressView!.ringWidth = 6
                    ringProgressView!.progress = 0.0
                    view.addSubview(ringProgressView!)
                    view.bringSubviewToFront(button)
                }
                else
                {
                    btnLabel.backgroundColor = UIColor.labelColor
                }
                self.view.addSubview(btnLabel)
                xvalue = xvalue + btnSize + 50;
                btnTag += 1
            }
            xvalue = 30;
            yvalue = yvalue + btnSize + 60;
        }
    }
    
    
    func scheduleNotification(notificationType: String) {
        print("background \(Date())")
        let content = UNMutableNotificationContent()
        content.title = notificationType
        content.body = "Timer has been restarted"
        print(status.audioTone)
        
        // adding tones to notification based on user selection
        if status.audioTone == "Default"
        {
            content.sound = UNNotificationSound.default
        }
        else
        {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(status.audioTone).wav"))
        }
        
        content.badge = 1
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: triger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error as Any)
        }
    }
    @objc func startTimer() {
        
        let intervalTime = status.startTime.timeIntervalSinceNow
        let displayTime = Int(intervalTime) + status.targetTime
        covertTimeInterval(interval: TimeInterval(displayTime))
        
        ringProgressView?.progress = abs(intervalTime / Double(btnSelected))
        
        // looping once the timer is completed
        if displayTime == 0
        {
            status.startTime = Date()
            scheduleNotification(notificationType: "Timer Completed")
        }
        
    }
    
    func covertTimeInterval(interval: TimeInterval) {
        
        
        let absInterval = abs(Int(interval))
        let seconds = absInterval % 60
        let minutes = absInterval / 60
        
        //initial value the time label
        var timeString = "5:00"
        
        //based on user selection time label text changes
        if minutes != 0 {
            timeString = String(minutes) + ":" + String(format: "%.2d", seconds)
            
        } else {
            timeString = String(seconds)
        }
        timeLabel.text = timeString
        
        //adding user selection to user defaults which can be accessed in Widget
        UserDefaults.init(suiteName: "group.mosaic.MosiacTimers")?.setValue(timeString, forKey: "availableTime")
        
    }
    @objc func buttonAction(sender: UIButton!) {
        print(sender.tag);
       
        let btnSize : Int = Int((self.view.frame.width-165)/3)
        let xvalue = Int(sender.frame.origin.x)
        let labels = self.view.subviews.compactMap { $0 as? UILabel }
        
        //checking for changing the label color to red based on which timer is active
        for label in labels {
            if label.tag == sender.tag*10
            {
                label.backgroundColor = UIColor.red
            }
            else if label.tag == 0
            {
                print("dont change")
            }
            else
            {
                label.backgroundColor = UIColor.labelColor
            }
        }
        startStopBtn.setTitle("STOP",for: .normal)
        ringProgressView?.removeFromSuperview()
        ringProgressView = RingProgressView(frame: CGRect(x: xvalue-6, y: Int(sender.frame.origin.y-6), width: btnSize+12, height: btnSize+12))
        ringProgressView!.startColor = UIColor.labelColor
        ringProgressView!.endColor = UIColor.labelColor
        ringProgressView!.backgroundRingColor = .clear
        ringProgressView!.ringWidth = 6
        ringProgressView!.progress = 0.0
        view.addSubview(ringProgressView!)
        view.bringSubviewToFront(sender)
        
        // changing default values to user selected current value
        status.targetTime = sender.tag
        btnSelected = status.targetTime
        status.startTime = Date()
        
        // Starting the timer
        if atimer != nil
        {
            atimer?.invalidate()
        }
        atimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.startTimer), userInfo: nil, repeats: true)
        
        // formatting the time to show in UI
        self.covertTimeInterval(interval: TimeInterval(btnSelected))
    }
}

// add custom colors in the UIColor class
extension UIColor {
    static var btnBorderColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
    static var btnTextColor = UIColor.init(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
    static var labelColor = UIColor.init(red: 0/255, green: 187/255, blue: 114/255, alpha: 1)
}


extension ViewController : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

//Bottom popup delegate methods
extension ViewController: BottomPopupDelegate {
    
    func bottomPopupViewLoaded() {
        print("bottomPopupViewLoaded")
    }
    
    func bottomPopupWillAppear() {
        print("bottomPopupWillAppear")
    }
    
    func bottomPopupDidAppear() {
        print("bottomPopupDidAppear")
    }
    
    func bottomPopupWillDismiss() {
        print("bottomPopupWillDismiss")
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupDidDismiss")
    }
    
    func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat) {
        print("bottomPopupDismissInteractionPercentChanged fromValue: \(oldValue) to: \(newValue)")
    }
}
