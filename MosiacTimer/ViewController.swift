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
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default
            .addObserver(self, selector: #selector(reinstateBackgroundTask),
                         name: UIApplication.didBecomeActiveNotification, object: nil)
        
        createBtn()
        if status.targetTime == 0
        {
            status.targetTime = 300
        }
        btnSelected = status.targetTime
        status.startTime = Date()
        if atimer != nil
        {
            atimer?.invalidate()
        }
        atimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.startTimer), userInfo: nil, repeats: true)
        registerBackgroundTask()
        //RunLoop.current.add((atimer ?? nil)!, forMode: RunLoop.Mode.common)
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
        print("settings")
    }
    
    func createBtn() {
        let btnSize : Int = Int((self.view.frame.width-165)/3)
        var xvalue = 30
        var yvalue = Int(timeLabel.frame.origin.y + timeLabel.frame.height + 30)
        var button = UIButton();
        var btnLabel = UILabel();
        for column in 0..<2{
            for row in 0..<3{
                button = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: btnSize , height: btnSize))
                button.backgroundColor = .clear
                switch column {
                    
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
                button.tag = btnTag * 60
                button.layer.borderColor = UIColor.btnBorderColor.cgColor
                button.titleLabel?.font = UIFont(name:"HelveticaNeue", size: 30.0)
                button.setTitleColor(UIColor.btnTextColor, for: .normal)
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                self.view.addSubview(button)
                
                btnLabel = UILabel(frame: CGRect(x: Int(button.frame.origin.x + 20), y: yvalue - 20, width: btnSize - 40 , height: 6))
                btnLabel.tag = btnTag * 600
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
        content.body = " "
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: triger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error as Any)
        }
    }
    @objc func startTimer() {
        
        if status.targetTime == -1 {
            let displayTime = Date().timeIntervalSince(status.startTime) + status.totalTime
            covertTimeInterval(interval: TimeInterval(displayTime))
        } else {
            let intervalTime = status.startTime.timeIntervalSinceNow
            let displayTime = Int(intervalTime) + status.targetTime
            covertTimeInterval(interval: TimeInterval(displayTime))
            ringProgressView?.progress = abs(intervalTime / Double(btnSelected))
            
            if displayTime == 0
            {
                status.startTime = Date()
                scheduleNotification(notificationType: "Timer Done")
            }
        }
    }
    
    func covertTimeInterval(interval: TimeInterval) {
        
        
        let absInterval = abs(Int(interval))
        let seconds = absInterval % 60
        let minutes = absInterval / 60
        
        if minutes != 0 {
            timeLabel.text = String(minutes) + ":" + String(format: "%.2d", seconds)
        } else {
            timeLabel.text = String(seconds)
        }
        
    }
    @objc func buttonAction(sender: UIButton!) {
        print(sender.tag);
       
        let btnSize : Int = Int((self.view.frame.width-165)/3)
        let xvalue = Int(sender.frame.origin.x)
        let labels = self.view.subviews.compactMap { $0 as? UILabel }
        
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
        status.targetTime = sender.tag
        btnSelected = status.targetTime
        status.startTime = Date()
        if atimer != nil
        {
            atimer?.invalidate()
        }
        atimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.startTimer), userInfo: nil, repeats: true)
        
        self.covertTimeInterval(interval: TimeInterval(btnSelected))
    }
    @objc func registerBackgroundTask() {
        print("Remaining time")
        backTimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(ViewController.registerBackgroundTask), userInfo: nil, repeats: false)
        print(UIApplication.shared.backgroundTimeRemaining)
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            [unowned self] in
            self.endBackgroundTask()
            
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    func restartBackgroundTask(){
        endBackgroundTask()
        registerBackgroundTask()
    }
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    @objc func reinstateBackgroundTask() {
        if atimer != nil && backgroundTask ==  .invalid {
            registerBackgroundTask()
        }
    }

}
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
