//
//  TimeStatusModel.swift
//  MosiacTimer
//
//  Created by Sanjeev on 17/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit

final class TimeStatusModel {
    
    var targetTime: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
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
    
    var stopWatchIsOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    var totalTime: Double {
        get {
            return UserDefaults.standard.double(forKey: #function)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    var audioTone: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? "nil"
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
}

