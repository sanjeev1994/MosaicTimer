//
//  TimeStatusModel.swift
//  MosiacTimer
//
//  Created by Sanjeev on 17/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit

final class TimeStatusModel {
    
    
    // To store user selection or default timer value
    var targetTime: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // To store the start time of the timer
    var startTime: Date {
        get {
            if let time = UserDefaults.standard.object(forKey: #function) as? Date {
                return time
            }
            return Date()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // To store the tone selection or default option
    var audioTone: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? "nil"
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
}

