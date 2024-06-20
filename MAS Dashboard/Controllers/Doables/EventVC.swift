//
//  EventVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 18/06/2024.
//

import UIKit
import FirebaseStorage

class EventVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var badgeSwitch: UISwitch!
    @IBOutlet weak var badgePickerView: UIPickerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var locDescLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locLinkField: UITextField!
    @IBOutlet weak var locDescField: UITextField!
    @IBOutlet weak var maxLimitField: UITextField!
    @IBOutlet weak var maxLimitLbl: UILabel!
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var locLinkLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var groupPickerView: UIPickerView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var groupSwitch: UISwitch!
    @IBOutlet weak var titleField: UITextField!
    
    let event = DoablesService.instance.selectedEvent
    var currentlyEditing = false
    var selectedGroup = Group()
    var selectedBadge = Badge()
    var imageUpdated = false
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        badgePickerView.delegate = self
        badgePickerView.dataSource = self
        setupView()
        choosePickerItems()
        let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(handleEndEditingTap))
        view.addGestureRecognizer(endEditingTap)
    }
    
    func pullImage() {
        spinner.startAnimating()
        imageView.image = AdminService.instance.findImage(id: event.id, ext: "jpg")
        if imageView.image?.size.width == 0 {
            let imageRef = storageRef.child("events/\(event.id).jpg")
            imageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                self.spinner.stopAnimating()
                if let error = error {
                    // uh-oh
                    print(error.localizedDescription)
                } else {
                    //success
                    self.imageView.image = UIImage(data: data!)
                    AdminService.instance.saveImage(id: self.event.id, image: data! as! Data, ext: "jpg")
                    self.spinner.stopAnimating()
                }
            }
        } else {
            self.spinner.stopAnimating()
        }
    }
    
    @objc func handleEndEditingTap() {
        UIView.animate(withDuration: 0.2) {
            self.view.superview!.endEditing(true)
            self.view.superview!.frame.origin.y = 0
        }
    }
    
    func setupView() {
        datePicker.minimumDate = Date()
        if event.id == "" {
            groupSwitch.isOn = false
            priceField.isHidden = false
            titleField.isHidden = false
            locDescField.isHidden = false
            locLinkField.isHidden = false
            maxLimitField.isHidden = false
            editBtn.isHidden = false
            groupSwitch.isEnabled = true
            badgeSwitch.isEnabled = true
            actionBtn.setTitle("Save", for: .normal)
            curtainView.isHidden = true
            descView.isEditable = true
        } else {
            pullImage()
            descView.text = event.desc
//            let community = CommunityService.instance.queryCommunity(id: event.communityID)
//            if community.id == "" {
//                communityToggle.isOn = false
//            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let foundDate = dateFormatter.date(from: event.date)
            datePicker.date =  foundDate ?? Date()
            if groupSwitch.isOn {
                for i in 0..<UserService.instance.groups.count {
                    if UserService.instance.groups[i].id == event.groupID {
                        groupPickerView.selectRow(i, inComponent: 0, animated: true)
                    }
                }
            }
            if currentlyEditing {
                groupSwitch.isEnabled = true
                badgeSwitch.isEnabled = true
                datePicker.isEnabled = true
                editBtn.isHidden = false
                priceField.isHidden = false
                titleField.isHidden = false
                locDescField.isHidden = false
                locLinkField.isHidden = false
                maxLimitField.isHidden = false
                priceField.text = "\(event.price)"
                titleField.text = event.title
                locDescField.text = event.locationDesc
                locLinkField.text = event.locationLink
                maxLimitField.text = "\(event.maxLimit)"
                actionBtn.setTitle("Save", for: .normal)
                curtainView.isHidden = true
                descView.isEditable = true
            } else {
                groupSwitch.isOn = event.groupID.count > 0
                badgeSwitch.isOn = event.badgeID.count > 0
                groupPickerView.isHidden = !groupSwitch.isOn
                badgePickerView.isHidden = !badgeSwitch.isOn
                datePicker.isEnabled = false
                groupSwitch.isEnabled = false
                badgeSwitch.isEnabled = false
                editBtn.isHidden = true
                priceField.isHidden = true
                titleField.isHidden = true
                locDescField.isHidden = true
                locLinkField.isHidden = true
                maxLimitField.isHidden = true
                priceLbl.text = "\(event.price) EGP"
                titleLbl.text = event.title
                locDescLbl.text = event.locationDesc
                locLinkLbl.text = event.locationLink
                maxLimitLbl.text = "\(event.maxLimit)"
                actionBtn.setTitle("Edit", for: .normal)
                curtainView.isHidden = false
                descView.isEditable = false
            }
        }
    }
    @IBAction func onGroupSwitch(_ sender: Any) {
        groupPickerView.isHidden = !groupSwitch.isOn
        if groupSwitch.isOn {
            badgeSwitch.isOn = (!groupSwitch.isOn)
        } else {
            selectedGroup = Group()
        }
        badgePickerView.isHidden = !badgeSwitch.isOn
        setupView()
        if groupSwitch.isOn {
            selectedGroup = UserService.instance.groups[0]
        }
    }
    
    @IBAction func onBadgeSwitch(_ sender: Any) {
        badgePickerView.isHidden = !badgeSwitch.isOn
        if badgeSwitch.isOn {
            groupSwitch.isOn = !badgeSwitch.isOn
        } else {
            selectedBadge = Badge()
        }
        groupPickerView.isHidden = !groupSwitch.isOn
        setupView()
        if badgeSwitch.isOn {
            selectedBadge = DoablesService.instance.badges[0]
        }
    }
    
    @IBAction func onEditClick(_ sender: Any) {
        present(imagePicker, animated: true)
        currentlyEditing = true
        setupView()
    }
    

    
    @IBAction func onActionClick(_ sender: Any) {
        if actionBtn.titleLabel?.text == "Edit" {
            currentlyEditing = true
            setupView()
        } else {
            spinner.startAnimating()
            actionBtn.isHidden = true
            editBtn.isHidden = true
//            var community = selectedCommunity
//            if !communityToggle.isOn {
//                community = Community()
//            }
            if !groupSwitch.isOn {
                selectedGroup = Group()
            }
            let newEvent = Event(id: event.id,
                                 title: titleField.text!,
                                 locationDesc: locDescField.text!,
                                 locationLink: locLinkField.text!,
                                 desc: descView.text!,
                                 badgeID: selectedBadge.id ?? "",
                                 groupID: selectedGroup.id ?? "",
                                 price: Int(priceField.text!)!,
                                 maxLimit: Int(maxLimitField.text!)!,
                                 date: datePicker.date.description)
            DoablesService.instance.updateEvent(event: newEvent) { Success in
                if Success {
                    if self.imageUpdated {
                        AdminService.instance.updateImage(filename: DoablesService.instance.selectedEvent.id, folderName: "events", image: self.imageView.image!.jpegData(compressionQuality: 0.5)!, ext: "jpg") { Success in
                            if Success {
                                self.dismiss(animated: true)
                            }
                        }
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            self.imageUpdated = true
            dismiss(animated: true)
            }
      }
}

extension EventVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == groupPickerView {
            //group
            return UserService.instance.groups.count
        } else {
            //badge
            return DoablesService.instance.badges.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == groupPickerView {
            //group
            return UserService.instance.groups[row].name
        } else {
            //badge
            return DoablesService.instance.badges[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == groupPickerView {
            //communities
            selectedGroup = UserService.instance.groups[row]
        } else {
            //token
            selectedBadge = DoablesService.instance.badges[row]
        }
    }
    
    func choosePickerItems() {
        if event.id != "" {
            if groupSwitch.isOn {
                for i in 0..<(UserService.instance.groups.count) {
                    if UserService.instance.groups[i].id == event.groupID {
                        groupPickerView.selectRow(i, inComponent: 0, animated: true)
                    }
                }
            }
            if badgeSwitch.isOn {
                for i in 0..<(DoablesService.instance.badges.count) {
                    if DoablesService.instance.badges[i].id == event.badgeID {
                        badgePickerView.selectRow(i, inComponent: 0, animated: true)
                    }
                }
            }
        }
    }
}
