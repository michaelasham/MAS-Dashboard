//
//  BadgeActivityCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 17/12/2023.
//

import UIKit
import Firebase

class BadgeActivityCell: UITableViewCell {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setupBadge(badge: BadgeActivity) {
        icon.image = UIImage.init(systemName: "trophy.circle")
        icon.image = AdminService.instance.findImage(id: badge.badge.id, ext: "png")
        if icon.image == UIImage.init(systemName: "trophy.circle") || icon.image?.size.width == 0 {
            let imageRef = storageRef.child("badges/\(badge.badge.id!).png")
            imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    
                DispatchQueue.main.async() {
                    self.icon.image = UIImage(data: data ?? Data())
                    AdminService.instance.saveImage(id: badge.badge.id, image: (UIImage(data: data ?? Data()) ?? UIImage()) as! Data, ext: "png")
                }
            }
        }

        title.text = badge.badge.name
        if badge.leader.id == nil {
            message.text = "This badge has been claimed before the creation of the integrated system"
        } else {
            message.text = "This badge has been awarded by the leader \(badge.leader.name)"
        }
        timestamp.text = badge.timestamp
    }
    
    func setupComment(comment: Comment) {
        icon.image = UIImage.init(systemName: "gear")
        title.text = comment.sender
        message.text = comment.message
        timestamp.text = comment.timestamp
    }
}
