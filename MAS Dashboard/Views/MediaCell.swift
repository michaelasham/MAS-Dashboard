//
//  MediaCell.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 26/10/2023.
//

import UIKit
import Firebase

class MediaCell: UICollectionViewCell {
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    var index = 0
    var material = Material()


    
    @IBAction func onRemoveClick(_ sender: Any) {
        let imageRef = storageRef.child("materials/\(material.id!)\(index).jpg")
        imageRef.delete { error in
            NotificationCenter.default.post(name: NOTIF_REMOVE_MEDIA, object: nil)
        }
    }
    
    @IBAction func onImageClick(_ sender: Any) {
        NotificationCenter.default.post(name: NOTIF_ADD_IMAGE, object: nil)
    }

    
    func setupCell(index: Int, material: Material, image: UIImage, isEditing: Bool) {
        addImageBtn.isHidden = true
        removeBtn.isHidden = true
        self.index = index
        self.material = material
        imageView.image = image
        if isEditing {
            if image == UIImage() {
                addImageBtn.isHidden = false
            } else {
                removeBtn.isHidden = false
            }
        }
    }
    
    
}


class curveView: UIView {
    override func awakeFromNib() {
        //self.view.layer.cornerRadius = self.view.size.width / 2
    }
}
