//
//  LoginViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 2/5/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    var currentSender: Sender?
    
    //    var SEGUE_LOGIN = "homeSegue"
    let SEGUE_CREATE_ACCOUNT = "createAccountSegue"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var username: String?
    var usernames : [String] = []
    
    @IBAction func createAccount(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_CREATE_ACCOUNT, sender: nil)
    }
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        Auth.auth().signIn(withEmail: email, password: password) {user, error in
            
            if let error = error{
                self.displayMessage(title: "Error", message:
                                        error.localizedDescription)
                return
            }
            guard let user = user else {
                return
            }
            
            
            let database = Firestore.firestore()
            database.collection("usernames").getDocuments { [self] (querySnapshot, error) in
                if let error = error{
                    return
                }
                if let snapshot = querySnapshot{
                    //                    for i in snapshot.documentChanges{
                    //                        let documentid = i.document.documentID
                    //                        let username = i.document.get("username") as! String
                    //                        self.usernames.append(username)
                    //                    }
                    //                    let a = self.usernames
                    //                    for i in self.usernames{
                    //                        print(i)
                    //                    }
                    
                    snapshot.documents.forEach { snapshot in
                        let id = snapshot["id"] as! String
                        if user.user.uid == id{
                            let a  = snapshot["username"] as! String
                            self.username = a
                            
                        }
                    }
                    
                }
                if let usernamez = username{
                    self.currentSender = Sender(id: user.user.uid, name: usernamez)
                }
                let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                appDelegate?.currentSender = self.currentSender
                let c = self.currentSender
                let b = appDelegate?.currentSender
                let a = appDelegate?.currentSender?.displayName
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            }
        }
        
        
        //            self.currentSender = Sender(id: user.user.uid, name: self.emailTextField.text!)
        
        //        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        //        appDelegate?.currentSender = self.currentSender
        //        let c = self.currentSender
        //        let b = appDelegate?.currentSender
        //        let a = appDelegate?.currentSender?.displayName
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        //
        //        // This is to get the SceneDelegate object from your view controller
        //        // then call the change root view controller function to change to main tab bar
        //        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
    }
    
    
    
    //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    //        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
    //        self.present(nextViewController, animated:true, completion:nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //    func displayMessage(title:String, message:String){
    //        let alertController = UIAlertController(title: title, message: message,
    //         preferredStyle: .alert)
    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
    //         handler: nil))
    //        self.present(alertController, animated: true, completion: nil)
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
