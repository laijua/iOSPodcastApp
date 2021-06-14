//
//  EnterUsernameViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 6/2/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EnterUsernameViewController: UIViewController, UITextFieldDelegate {
// reason for this view controller is because i need to be logged in before i can access collection of username. the rule in cloud firestore: allow read, write: if request.auth.uid != null;
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createAccountUIButton: UIButton!

    var uid:String?
    private var usernameAdded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccountUIButton.layer.cornerRadius = 10
        
        // for pushing view up when keyboard is shown
//        https://fluffy.es/move-view-when-keyboard-is-shown/#tldr
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          
              // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // https://stackoverflow.com/questions/26594510/can-you-detect-when-a-uiviewcontroller-has-been-dismissed-or-popped
        if isBeingDismissed &&  !usernameAdded{
            let user = Auth.auth().currentUser
            // delete account if the user dismisses the view
            user?.delete { error in
              if let _ = error {
                return
              }
            }
        }
    }

    @IBAction func AddUsername(_ sender: Any) {
        
        
        let child = addSpin()
        
        guard let newUsername = self.usernameTextField.text, newUsername.replacingOccurrences(of: " ", with: "").count > 0
        else {
            displayMessage(title: "Username can't be empty", message: "Username can't be empty")
            removeSpin(child)
            return
        }
        
        if newUsername.contains(","){ // if username contains comma. reason for this is because i use comma for my logic in for chat room names
            self.displayMessage(title: "Username cannot contain commas", message: "Username cannot contain commas")
            self.removeSpin(child)
            return
        }
        
        
        let database = Firestore.firestore()
            //lowercase version of username is also stored as firebase doesnt have any functionality to lowercase their values
        database.collection("usernames").whereField("usernameLowercased", isEqualTo: newUsername.lowercased())
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    return
                } else {
                    var doesExist = false
                    for _ in querySnapshot!.documents {
                        doesExist = true
                        break
                        // if i can loop through document, it means it exists and i can just break
                    }
                    
                    if doesExist{ // username already exists
                        self.displayMessage(title: "Error", message: "Username is already in use")
                        self.removeSpin(child)
                        return
                    }
                    else{
                        
                        guard let uid = self.uid else {return}
                        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                        appDelegate?.currentSender = Sender(id: uid, name: self.usernameTextField.text!)
                        
                        database.collection("usernames").addDocument(data: ["username" : newUsername,
                                                                            "id": uid,
                                                                            "usernameLowercased": newUsername.lowercased()])
                        self.usernameAdded = true
                        self.removeSpin(child)

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController") as UITabBarController

                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                        
                        // since new user, i bring them to recommendation/search screen
                        mainTabBarController.selectedIndex = 1
                        mainTabBarController.tabBar.barTintColor = UIColor(named: "Teal")
                    }
                }
            }
        
        
    }
    
    // dismiss keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
