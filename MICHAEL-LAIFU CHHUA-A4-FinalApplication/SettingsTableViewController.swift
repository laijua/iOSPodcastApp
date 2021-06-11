//
//  SettingsTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    private let SECTION_ACCOUNT = 0
    private let SECTION_AUTHOR = 1
    private let SECTION_ACKNOWLEDGEMENT = 2
    
    
    private let CELL_SETTINGS = "settingCell"
    private let CELL_ACK_AUTHOR = "acknowledgeAndAuthorCell"

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_ACCOUNT{
            return "Account"
        }
        if section == SECTION_AUTHOR{
            return "Author"
        }
        return "Acknowledgements"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ACCOUNT{
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SETTINGS, for: indexPath) as! SettingsTableViewCell
        
        cell.signOutBlock = {
            
            do {
             try Auth.auth().signOut()
            } catch {
             return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")

                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController)
        }
        
        return cell
        }
        
        if indexPath.section == SECTION_AUTHOR{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ACK_AUTHOR, for: indexPath)
            cell.textLabel?.text = "Michael-Laifu Chhua"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ACK_AUTHOR, for: indexPath)
        cell.textLabel?.text = "This app is powered by Listen Notes, Firebase and MessageKit \n \n Images used: \n https://www.vecteezy.com/vector-art/422662-microphone-icon-vector-illustration\n \nYoutube Tutorials: \n https://www.youtube.com/watch?v=s4skYI4GaOg \n https://www.youtube.com/watch?v=hV1DqMpQG7A \n https://www.youtube.com/watch?v=_Qn3UGad3lg \n \n Other resources \n https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/ \n https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/DocumentChange\n https://firebase.google.com/docs/firestore/query-data/queries#array_membership \n https://onurtuna.medium.com/custom-section-header-for-uitableview-4a6d91ce906c \n https://programmingwithswift.com/expand-collapse-uitableview-section-with-swift/ \n https://freakycoder.com/ios-notes-46-how-to-embed-scrollview-to-the-existing-view-a9fde5d8c123 \n https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening \n https://fluffy.es/move-view-when-keyboard-is-shown/#tldr\n \n A bunch of Stack Overflow posts: \n https://stackoverflow.com/questions/29912489/how-to-remove-all-navigationbar-back-button-title \n https://stackoverflow.com/questions/28240848/how-to-save-an-array-of-objects-to-nsuserdefault-with-swift/48438338#48438338 \n https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected \n https://stackoverflow.com/questions/29386531/how-to-detect-when-avplayer-video-ends-playing/52747450 \n https://stackoverflow.com/questions/29068243/swift-how-to-disable-user-interaction-while-touch-action-is-being-carried-out \n https://stackoverflow.com/questions/56262177/error-when-setting-uisliders-min-and-max-values \n https://stackoverflow.com/questions/28733936/change-color-of-back-button-in-navigation-bar \n https://stackoverflow.com/questions/31583648/hide-navigation-bar-but-keep-the-bar-button/31583908 \n https://stackoverflow.com/questions/19802336/changing-font-size-for-uitableview-section-headers \n https://stackoverflow.com/questions/28735513/how-to-set-heading-subheading-body-footnote-and-captions-font-for-dynamic-ty \n https://stackoverflow.com/questions/31673607/swift-tableview-in-viewcontroller \n https://stackoverflow.com/questions/57943765/swift-firestore-delete-document \n https://stackoverflow.com/questions/27372595/issues-adding-uitableview-inside-a-uiviewcontroller-in-swift \n https://stackoverflow.com/questions/29812168/could-not-cast-value-of-type-uitableviewcell-to-appname-customcellname \n https://stackoverflow.com/questions/29035876/swift-custom-uitableviewcell-label-is-always-nil \n https://stackoverflow.com/questions/57943765/swift-firestore-delete-document \n https://stackoverflow.com/questions/25325923/programmatically-switching-between-tabs-within-swift \n https://stackoverflow.com/questions/43540728/push-to-another-tabs-viewcontroller \n https://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key \n https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected \n https://stackoverflow.com/questions/25325923/programmatically-switching-between-tabs-within-swift \n https://stackoverflow.com/questions/43540728/push-to-another-tabs-viewcontroller \n https://stackoverflow.com/questions/26594510/can-you-detect-when-a-uiviewcontroller-has-been-dismissed-or-popped \n https://stackoverflow.com/questions/25325923/programmatically-switching-between-tabs-within-swift \n https://stackoverflow.com/questions/43540728/push-to-another-tabs-viewcontroller \n https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift?page=1&tab=votes#tab-top \n https://stackoverflow.com/questions/44195986/uitableview-header-dynamic-height-in-run-time \n https://stackoverflow.com/questions/28129401/determining-if-swift-dictionary-contains-key-and-obtaining-any-of-its-values \n https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift \n https://stackoverflow.com/questions/30022780/uibarbuttonitem-in-navigation-bar-programmatically \n https://stackoverflow.com/questions/30105189/how-to-add-a-button-with-click-event-on-uitableviewcell-in-swift \n https://stackoverflow.com/questions/28240848/how-to-save-an-array-of-objects-to-nsuserdefault-with-swift/48438338#48438338 \n https://stackoverflow.com/questions/35700281/date-format-in-swift \n https://stackoverflow.com/questions/40714893/how-to-convert-milliseconds-to-date-string-in-swift-3 \n https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds \n https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected \n https://stackoverflow.com/questions/35700281/date-format-in-swift \n https://stackoverflow.com/questions/25492491/make-a-uibarbuttonitem-disappear-using-swift-ios \n https://stackoverflow.com/questions/61909665/how-to-make-null-value-in-a-field-in-firestore-document-using-swift \n https://stackoverflow.com/questions/42137285/split-string-into-substring-with-component-separated-by-string-swift \n https://stackoverflow.com/questions/32061500/stop-uitextfield-from-expanding-horizontally \n https://stackoverflow.com/questions/28170520/ios-how-to-set-app-icon-and-launch-images \n https://stackoverflow.com/questions/26837371/how-to-change-uibutton-image-in-swift \n https://stackoverflow.com/questions/27374759/programmatically-navigate-to-another-view-controller-scene/46676095 \n https://stackoverflow.com/questions/39450124/swift-programmatically-navigate-to-another-view-controller-scene\n https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value \n https://stackoverflow.com/questions/36028493/add-a-scrollview-to-existing-view \n https://stackoverflow.com/questions/38036349/cgsizemake-unavailable-in-swift?noredirect=1&lq=1 \n https://stackoverflow.com/questions/2824435/uiscrollview-not-scrolling \n https://stackoverflow.com/questions/52162482/textview-is-not-scrolling-vertically-in-the-scrollview-swift-4 \n https://stackoverflow.com/questions/4945092/reordering-cells-in-uitableview \n https://stackoverflow.com/questions/24772457/swift-reorder-uitableview-cells \n https://stackoverflow.com/questions/28124119/convert-html-to-plain-text-in-swift"
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        // https://stackoverflow.com/questions/19802336/changing-font-size-for-uitableview-section-headers
        // https://stackoverflow.com/questions/28735513/how-to-set-heading-subheading-body-footnote-and-captions-font-for-dynamic-ty
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // make the cells not selectable, sign out button still tappable
        return nil
    }


}
