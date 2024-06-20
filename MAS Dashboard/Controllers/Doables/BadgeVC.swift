//
//  BadgeVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 25/10/2023.
//

import UIKit
import Firebase

class BadgeVC: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var prerequisitesSwitch: UISwitch!
    @IBOutlet weak var availableSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var descField: UITextView!
    
    let badge = DoablesService.instance.selectedBadge
    
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    let imagePicker = UIImagePickerController()
    var image = UIImage()
    
    var containsImage = false
    var picChanged = false
    var new = true

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        tableView.delegate = self
        tableView.dataSource = self
        if let id = badge.id {
            new = false
            editBtn.isHidden = false
            nameLbl.isHidden = false
            descLbl.isHidden = false
            nameField.isHidden = true
            descField.isHidden = true
            addBtn.isHidden = true
            nameLbl.text = badge.name
            descLbl.text = badge.desc
            saveBtn.isHidden = true
            availableSwitch.isOn = badge.available
            prerequisitesSwitch.isOn = badge.prerequisites
            availableSwitch.isEnabled = false
            prerequisitesSwitch.isEnabled = false
            tableView.isUserInteractionEnabled = false
            
            let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(handleEndEditingTap))
            view.addGestureRecognizer(endEditingTap)
            self.tableView.isHidden = !prerequisitesSwitch.isOn
            self.pullImage()
        } else {
            //new
            activityIndicator.stopAnimating()
            editBtn.isHidden = true
            nameLbl.isHidden = true
            descLbl.isHidden = true
            prerequisitesSwitch.isOn = false
            availableSwitch.isOn = false
            self.tableView.isHidden = true

        }
    }
    func pullImage() {
        imageView.image = AdminService.instance.findImage(id: badge.id, ext: "png")
        if imageView.image?.size.width == 0 {
            let imageRef = storageRef.child("badges/\(badge.id!).png")
            imageRef.getData(maxSize: 15 * 1024 * 1024) { [self] data, error in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    // uh-oh
                    print(error.localizedDescription)
                    self.containsImage = false
                } else {
                    //success
                    self.imageView.image = UIImage(data: data!)
                    self.containsImage = true
                    AdminService.instance.saveImage(id: badge.id, image: data!, ext: "png")
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            self.containsImage = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc func handleEndEditingTap() {
        UIView.animate(withDuration: 0.2) {
            self.view.superview!.endEditing(true)
            self.view.superview!.frame.origin.y = 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PrerequisitesCell", for: indexPath) as? PrerequisitesCell {
            let badge = DoablesService.instance.badges[indexPath.row]
            var editable = true
            if badge.id == DoablesService.instance.selectedBadge.id {
                editable = false
            }
            var toggle = false
            if new == false {
                if DoablesService.instance.selectedBadge.prerequisites {
                    if DoablesService.instance.selectedBadge.prerequisiteBadges!.contains(badge.id) {
                        toggle = true
                    }
                }
            }


            cell.setupCell(name: badge.name, toggle: toggle, editable: editable, togglable: true)
            return cell
        }

        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DoablesService.instance.badges.count
    }
    
    @IBAction func onAddClick(_ sender: Any) {
        present(imagePicker, animated: true)
    }
                          
    @IBAction func onEditClick(_ sender: Any) {
        saveBtn.isHidden = false
        editBtn.isHidden = true
        nameLbl.isHidden = true
        tableView.isUserInteractionEnabled = true
        descLbl.isHidden = true
        descField.isHidden = false
        nameField.isHidden = false
        addBtn.isHidden = false
        descField.text = badge.desc
        nameField.text = badge.name
        availableSwitch.isEnabled = true
        prerequisitesSwitch.isEnabled = true
        if containsImage {
            addBtn.setTitle("REPLACE", for: .normal)
        } else {
            addBtn.setTitle("+", for: .normal)
        }
    }
    
    @IBAction func onSaveClick(_ sender: Any) {
        activityIndicator.startAnimating()
        var prerequisitesList = [String]()
        if prerequisitesSwitch.isOn {
            for i in 0...(DoablesService.instance.badges.count - 1) {
                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PrerequisitesCell {
                    if cell.toggleSwitch.isOn {
                        prerequisitesList.append(DoablesService.instance.badges[i].id)
                    }
                }
            }
        }
        if imageView.image?.size.width.isZero ?? true {
            addBtn.tintColor = .red

        } else if let id = badge.id {
            let badge = Badge(id: self.badge.id, name: nameField.text, desc: descField.text, available: availableSwitch.isOn, prerequisites: prerequisitesSwitch.isOn, prerequisiteBadges: prerequisitesList)
            if self.picChanged {
                let format = checkImageFormat(imageView.image!)
                if format == "PNG" {
                    DoablesService.instance.replaceImage(image: imageView.image!) { Success in
                        if Success {
                            print("tamama")
                        }
                    }

                } else {
                    self.imageView.image = UIImage()
                    addBtn.isHidden = false
                    addBtn.setTitle("PNG Only. \(format!) not allowed", for: .normal)
                }
            }
            DoablesService.instance.updateBadgeDetails(badge: badge) { Success in
                if Success {
                    self.dismiss(animated: true)
                }
            }
        } else {
            //new badge
            if prerequisitesSwitch.isOn {
                //loop to check the checked prerequisites
            }
            let badge = Badge(id: "", name: nameField.text, desc: descField.text, available: availableSwitch.isOn, prerequisites: prerequisitesSwitch.isOn, prerequisiteBadges: prerequisitesList)
            let format = checkImageFormat(imageView.image!)
            if format == "PNG" {
                DoablesService.instance.addBadge(badge: badge, image: imageView.image!, completion: { Success in
                if Success {
                    self.dismiss(animated: true)
                }
            })
            } else {
                self.imageView.image = UIImage()
                addBtn.setTitle("PNG Only", for: .normal)
            }

        }


    }

    @IBAction func onPrerequisitesSwitch(_ sender: Any) {
        tableView.isHidden = !prerequisitesSwitch.isOn
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            self.image = image
            dismiss(animated: true)
            addBtn.isHidden = true
            self.picChanged = true
            }
      }
    
    
    func getImageFormat(data: Data) -> String? {
        var c = [UInt8](repeating: 0, count: 1)
        (data as NSData).getBytes(&c, length: 1)

        switch c {
        case [0xFF]:
            return "JPEG"
        case [0x89]:
            return "PNG"
        default:
            return nil
        }
    }

    func checkImageFormat(_ image: UIImage) -> String? {
        if let data = image.pngData() {
           return getImageFormat(data: data)
       } else if let data = image.jpegData(compressionQuality: 1.0) {
            return getImageFormat(data: data)
        }
        return nil
    }
}
