//
//  CreateAccountViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 10/5/21.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var continueUIButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueUIButton.layer.cornerRadius = 10
        
        
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
    
    
    @IBAction func createAccount(_ sender: Any) {
        let child = addSpin()
        
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        guard let confirmPassword = confirmPasswordTextField.text else {return}
        
        if password != confirmPassword{
            removeSpin(child)
            displayMessage(title: "Password did't match", message: "Passwords didn’t match. Try again.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [self] (user, error) in
            if let error = error {
                removeSpin(child)
                self.displayMessage(title: "Error", message:
                                        error.localizedDescription)
            }
            else{
                
                guard let user = user else {return}
                removeSpin(child)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let enterUsernameViewController = storyboard.instantiateViewController(identifier: "EnterUsernameViewController") as EnterUsernameViewController
                enterUsernameViewController.uid = user.user.uid
                self.present(enterUsernameViewController, animated:  true, completion:nil)
            }
        }
    }
    
    // dismiss keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}





