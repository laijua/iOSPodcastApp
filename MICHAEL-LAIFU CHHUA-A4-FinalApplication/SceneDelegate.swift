//
//  SceneDelegate.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
        UIView.transition(with: window,
                              duration: 0.5,
                              options: [.transitionCrossDissolve],
                              animations: nil,
                              completion: nil)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // if user is logged in before
        if Auth.auth().currentUser != nil {
            // instantiate the main tab bar controller and set it as root view controller
            // using the storyboard identifier we set earlier
            guard let user = Auth.auth().currentUser else {return}
            guard let email = user.email else {return}
            
            
            let database = Firestore.firestore()
            database.collection("usernames").getDocuments { [self] (querySnapshot, error) in
                if let _ = error{
                    return
                }
                if let snapshot = querySnapshot{
                   
                    
                    snapshot.documents.forEach { snapshot in
                        let id = snapshot["id"] as! String
                        if user.uid == id{
                            let a  = snapshot["username"] as! String
                            let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                            appDelegate?.currentSender =  Sender(id: user.uid, name: a)
                          
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                            // This is to get the SceneDelegate object from your view controller
                            // then call the change root view controller function to change to main tab bar
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                            
                        }
                    }
                    
                }
             
            }
            
        } else {
            // if user isn't logged in
            // instantiate the navigation controller and set it as root view controller
            // using the storyboard identifier we set earlier
            let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
            window?.rootViewController = loginViewController
        }
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

