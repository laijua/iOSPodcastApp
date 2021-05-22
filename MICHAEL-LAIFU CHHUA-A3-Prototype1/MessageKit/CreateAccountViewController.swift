//
//  CreateAccountViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 10/5/21.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    
    var currentSender: Sender?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @IBAction func createAccount(_ sender: Any) {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        
        
        let database = Firestore.firestore()
        
        
        guard let newUsername = self.usernameTextField.text, newUsername.count > 0 else {return}
        var doesExist = false
        
        database.collection("usernames").getDocuments { (querySnapshot, error) in
            if let error = error{
                return
            }
            if let snapshot = querySnapshot{
                snapshot.documents.forEach { snapshot in
                    let username = snapshot["username"] as! String
                    if newUsername.lowercased() == username.lowercased(){
                        doesExist = true
                    }
                }
                if doesExist{
                    self.displayMessage(title: "Error", message: "Username is already taken")
                    return
                }
                else{
                    
                    
                    Auth.auth().createUser(withEmail: email, password: password) { [self] (user, error) in
                        if let error = error {
                         self.displayMessage(title: "Error", message:
                         error.localizedDescription)
                        }
                        
                        guard let user = user else {
                         return
                        }
                        
                        
                        database.collection("usernames").addDocument(data: ["username" : newUsername,
                                                                            "id": user.user.uid])
                        
                        
                        self.currentSender = Sender(id: user.user.uid, name: self.usernameTextField.text!)
                        
                        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                        appDelegate?.currentSender = self.currentSender
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        
                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                    }
                    
                    
                    
                    
                }
            }
            
        }
        
        
        
//        Auth.auth().createUser(withEmail: email, password: password) { [self] (user, error) in
//            if let error = error {
//             self.displayMessage(title: "Error", message:
//             error.localizedDescription)
//            }
//
//            guard let user = user else {
//             return
//            }
//
//
//            database.collection("usernames").addDocument(data: ["username" : newUsername,
//                                                                "id": user.user.uid])
//
//
//            self.currentSender = Sender(id: user.user.uid, name: self.usernameTextField.text!)
//
//            let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
//            appDelegate?.currentSender = self.currentSender
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
//
//            // This is to get the SceneDelegate object from your view controller
//            // then call the change root view controller function to change to main tab bar
//            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
//        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
