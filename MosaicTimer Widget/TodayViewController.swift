//
//  TodayViewController.swift
//  MosaicTimer Widget
//
//  Created by Sanjeev on 18/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UIGestureRecognizerDelegate {
        
    @IBOutlet var timeLabel: UILabel!
    var atimer: Timer?
    @IBOutlet var openBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(openBtn)
    
        //timer for displaying the timer in the widget
        if atimer != nil
        {
            atimer?.invalidate()
        }
        atimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TodayViewController.startTimer), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    @objc func startTimer() {
      
        //accessing value from userdefaults and displaying it in widget
        if let timeFromApp = UserDefaults.init(suiteName: "group.mosaic.MosiacTimers")?.value(forKey: "availableTime") {
            timeLabel.text = timeFromApp as? String
        }
    }
    
    // opening the app when the widget in pressed
    @IBAction func openBtnAction(_ sender: UIButton) {
        if let url = URL(string: "open://")
        {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
