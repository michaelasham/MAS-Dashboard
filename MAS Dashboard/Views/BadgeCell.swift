//
//  BadgeCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 25/10/2023.
//

import UIKit
import Firebase

class BadgeCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(badge: Badge) {
        logo.image = UIImage.init(systemName: "trophy.circle")

        titleLbl.text = badge.name
        if badge.available == false {
            titleLbl.textColor = .gray
        } else {
            titleLbl.textColor = .label
        }
        if FilesManagement.instance.checkImageValidity(id: badge.id, lastUpdated: badge.lastUpdated) {
            logo.image = FilesManagement.instance.findImage(id: badge.id)
        } else {
            if logo.image == UIImage.init(systemName: "trophy.circle") || logo.image?.size.width == 0 {
                let imageRef = storageRef.child("badges/\(badge.id!).png")
                imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                        
                    DispatchQueue.main.async() {
                        self.logo.image = UIImage(data: data ?? Data())
                        FilesManagement.instance.saveImage(id: badge.id, image: UIImage(data: data ?? Data()) ?? UIImage())
                    }
                }
            }
        }
    }
    
}






extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
   func downloadImage(from url: URL) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            self.image = UIImage(data: data)
         }
      }
   }
}
