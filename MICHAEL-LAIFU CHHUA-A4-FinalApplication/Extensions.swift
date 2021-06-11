//
//  Extensions.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 22/5/21.
//

import UIKit
import FirebaseFirestore
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
    
    func playlistButtonInitialisation(_ episode:EpisodeData) -> (() -> Void){
        return {
            let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
            
            appDelegate?.queueArray.append(episode)
            let queueData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.queueArray)
            
            UserDefaults.standard.set(queueData, forKey: "queue")
        }
    }
    
    func addSpin()-> SpinnerViewController {
        let child = SpinnerViewController()
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        return child
    }
    
    func removeSpin(_ child: SpinnerViewController){
        //remove the spinner view controller
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        return
    }
    
    func usernameTapped(_ name: String, _ delegate: TabBarSwitchDelegate, _ presentThroughNavigationController: Bool) -> (() -> Void) {
        // returns a function that creates an account view and pushes it
        return {
            let child = self.addSpin()
            
            let database = Firestore.firestore()
            let usernamesRef = database.collection("usernames")
            usernamesRef.whereField("username", isEqualTo: name).getDocuments() { (querySnapshot, err) in
                if let err = err{
                    return
                }
                else{
                    
                    for document in querySnapshot!.documents {
                        let username = document["username"] as! String
                        var podcastsFollowed = [String]()
                        let id = document["id"] as! String
                        usernamesRef.document(document.documentID).collection("favourites").getDocuments() { (querySnapshot, err) in
                            if let snapshot = querySnapshot{
                                snapshot.documents.forEach{ snapshot in
                                    let podcastId = snapshot["podcastId"] as! String
                                    podcastsFollowed.append(podcastId)
                                }
                                
 
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
                                nextViewController.usernameOfAnother = username
                                nextViewController.idOfAnother = id
                                nextViewController.favouritePodcastsIds = podcastsFollowed
                                nextViewController.tabBarSwitchDelegate = delegate
//                                https://stackoverflow.com/questions/25492491/make-a-uibarbuttonitem-disappear-using-swift-ios
                                nextViewController.searchUIBarButtonItem.isEnabled = false
                                nextViewController.searchUIBarButtonItem.tintColor = UIColor.clear
                                if presentThroughNavigationController{
                                    self.navigationController?.pushViewController(nextViewController, animated: true)
                                }
                                else{
                                self.present(nextViewController, animated:true, completion:nil)
                                }
                                self.removeSpin(child)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
      }
}


// extensions to convert html to string
//https://stackoverflow.com/questions/28124119/convert-html-to-plain-text-in-swift

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
