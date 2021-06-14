//
//  LoginViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 2/5/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var signInUIButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    private let SEGUE_CREATE_ACCOUNT = "createAccountSegue"
    private var username: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInUIButton.layer.cornerRadius = 10
    }
    
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
                if let _ = error{
                    return
                }
                if let snapshot = querySnapshot{
                    snapshot.documents.forEach { snapshot in
                        let id = snapshot["id"] as! String
                        if user.user.uid == id{
                            let username = snapshot["username"] as! String
                            self.username = username
                            
                        }
                    }
                    
                }
                if let username = username{
                    appDelegate?.currentSender = Sender(id: user.user.uid, name: username)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            }
        }
    }
    
    
    
    //    https://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key
    // dismiss keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
