//
//  UIViewControllerExtension.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 22/5/21.
//

import UIKit
extension UIViewController {
    func displayMessage(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dateFormatter(date: Date) -> String  {
        // https://stackoverflow.com/questions/35700281/date-format-in-swift
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm dd/MM/yy"
        let formattedDate = dateFormatterGet.string(from: date)
        return formattedDate
    }
    
}
