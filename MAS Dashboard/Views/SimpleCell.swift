//
//  MaterialCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 25/10/2023.
//

import UIKit

class SimpleCell: UITableViewCell {

    
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
        
    func setupCell(title: String, subtitle: String, active: Bool) {
        if !active {
            titleLbl.textColor = .gray
        } else {
            titleLbl.textColor = .label
        }
        titleLbl.text = title
        typeLbl.text = subtitle
    }
    
}
