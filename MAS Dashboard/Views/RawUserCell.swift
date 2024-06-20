//
//  RawUserCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 10/12/2023.
//

import UIKit

class RawUserCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(name: String) {
        titleLbl.text = name
    }
}
