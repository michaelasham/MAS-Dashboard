//
//  PrerequisitesCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 26/10/2023.
//

import UIKit

class PrerequisitesCell: UITableViewCell {

    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onSwitchClick(_ sender: Any) {
        NotificationCenter.default.post(name: NOTIF_SWITCH_CLICK, object: nil)
    }
    
    func setupCell(name: String, toggle: Bool, editable: Bool, togglable: Bool) {
        if togglable {
            toggleSwitch.isHidden = false
        } else {
            toggleSwitch.isHidden = true
        }
        titleLbl.text = name
        toggleSwitch.isOn = toggle
        if editable == false {
            toggleSwitch.isEnabled = false
            toggleSwitch.isOn = false
            titleLbl.textColor = UIColor.gray
        } else {
            toggleSwitch.isEnabled = true
            titleLbl.textColor = .label
        }
    }
    


}
