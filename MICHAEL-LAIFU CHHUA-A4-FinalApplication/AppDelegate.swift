//
//  AppDelegate.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import Firebase


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var currentSender: Sender?
    let apiKey = "c975de1e599a46a6889c7e7006a493eb"
    
    var queueArray: [EpisodeData] =  []
    var nowPlaying: [EpisodeData] =  []
    var previousAudio: [EpisodeData] =  []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // remove all navigationbar back button title
//        https://stackoverflow.com/questions/29912489/how-to-remove-all-navigationbar-back-button-title
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "Helvetica-Bold", size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]
        
            BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
            BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for:UIBarMetrics.default)
        
        FirebaseApp.configure()
        
        //https://stackoverflow.com/questions/28240848/how-to-save-an-array-of-objects-to-nsuserdefault-with-swift/48438338#48438338
        let queueData = UserDefaults.standard.object(forKey: "queue") as? NSData
        if let queueData = queueData{
            queueArray = NSKeyedUnarchiver.unarchiveObject(with: queueData as! Data ) as? [EpisodeData] ?? []
        }
        
        let nowPlayingData = UserDefaults.standard.object(forKey: "nowPlaying") as? NSData
        if let nowPlayingData = nowPlayingData{
            nowPlaying = NSKeyedUnarchiver.unarchiveObject(with: nowPlayingData as! Data ) as? [EpisodeData] ?? []
        }
        
        if nowPlaying.count == 0 && queueArray.count > 0 {
            let episode = queueArray.removeFirst()
            nowPlaying = [episode]
            
            let queueData = NSKeyedArchiver.archivedData(withRootObject: queueArray)
            UserDefaults.standard.set(queueData, forKey: "queue")
            
           
            let nowPlayingData = NSKeyedArchiver.archivedData(withRootObject: nowPlaying)
            UserDefaults.standard.set(nowPlayingData, forKey: "nowPlaying")
            
        }
        
        let previousData = UserDefaults.standard.object(forKey: "previous") as? NSData
        if let previousData = previousData{
            previousAudio = NSKeyedUnarchiver.unarchiveObject(with: previousData as! Data ) as? [EpisodeData] ?? []
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

