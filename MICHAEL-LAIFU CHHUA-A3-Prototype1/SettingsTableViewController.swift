//
//  SettingsTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    let SECTION_SETTINGS = 0
    let SECTION_FORUM = 1
    
    
    let CELL_SETTINGS = "settingCell"

    @IBAction func switchChanged(_ sender: Any) {
    }
    
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
        if section == SECTION_FORUM{
            return "Forum"
        }
        return " "
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SETTINGS, for: indexPath) as! SettingsTableViewCell
        
        cell.settingLabel.text = "settings 1"
        cell.settingSwitch.tag = indexPath.row
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        // https://stackoverflow.com/questions/19802336/changing-font-size-for-uitableview-section-headers
        // https://stackoverflow.com/questions/28735513/how-to-set-heading-subheading-body-footnote-and-captions-font-for-dynamic-ty
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
//        header.textLabel?.frame = header.bounds
//        header.textLabel?.textAlignment = .center
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
