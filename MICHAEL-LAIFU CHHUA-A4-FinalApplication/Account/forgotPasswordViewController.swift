//
//  forgotPasswordViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 6/9/21.
//

import UIKit
import FirebaseAuth

class forgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordUIButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetPasswordUIButton.layer.cornerRadius = 10
        
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
    
    
    @IBAction func resetPassword(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error{
                self.displayMessage(title: "Error", message:
                                        error.localizedDescription)
                return
            }
            
            let alertController = UIAlertController(title: "Instructions Sent", message: "Instructions to reset your password were sent to \(email)",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default,
                                                    handler: {_ in self.dismiss(animated: true, completion: nil)}))
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    // dismiss keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
