//
//  AppDelegate.swift
//  MosiacTimer
//
//  Created by Sanjeev on 17/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundTasks = BackgroundTask()
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    let status = TimeStatusModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //setting default time to 5mins
        status.targetTime = 300
        
        // clear the notification count from app icon
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //asking permission to send notification
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       //starting backgroundtask to stop app to become inactive
        backgroundTasks.startBackgroundTask()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // stopping backgroundtast
        backgroundTasks.stopBackgroundTask()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // setting default value to show in widget after app is killed
        UserDefaults.init(suiteName: "group.mosaic.MosiacTimers")?.setValue("05:00", forKey: "availableTime")
    }
    
    // 3d touch button action
    func application(_ application: UIApplication,
                              performActionFor shortcutItem: UIApplicationShortcutItem,
                              completionHandler: @escaping (Bool) -> Void){
        print(shortcutItem.localizedTitle)
        let titleString : String = shortcutItem.localizedTitle
        var fullTitleArr = titleString.split{$0 == " "}.map(String.init)
        let intPart: String = fullTitleArr[0]
       // var stringPart: String? = fullTitleArr.count > 1 ? fullTitleArr[1] : nil
        let intValue : Int = Int(intPart ) ?? 0
        status.targetTime = intValue * 60
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController  = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.window?.rootViewController = initViewController
        self.window?.makeKeyAndVisible()
    }
    
    //tapping widget action
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return true
    }
}

