//
//  PatrolVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 17/12/2023.
//

import UIKit

class PatrolVC: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var ctaLbl: UILabel!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var subtitleField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    var patrol = UserService.instance.selectedPatrol
    var groupMembers = [User]()
    
    var currentlyEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        queryGroupMembers()
        if patrol.id == nil || patrol.id == "" {
            currentlyEditing == true
        }
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(onSwitchClick), name: NOTIF_SWITCH_CLICK, object: nil)
    }
    
    @objc func onSwitchClick() {
        if patrol.members != nil {
            patrol.members.removeAll()
        }
        for i in 0...(groupMembers.count - 1) {
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PrerequisitesCell {
                if cell.toggleSwitch.isOn {
                    if patrol.members != nil {
                        patrol.members.append(groupMembers[i])
                    } else {
                        patrol.members = [groupMembers[i]]
                    }
                }
            }
            
        }
    }
    
    func setupViews() {
        ctaLbl.isHidden = true
        if currentlyEditing {
            spinner.stopAnimating()
            segmentedControl.isHidden = false
            titleField.isHidden = false
            subtitleField.isHidden = false
            titleLbl.isHidden = true
            subtitleLbl.isHidden = true
            titleField.text = patrol.name
            subtitleField.text = patrol.desc
            saveBtn.isHidden = false
            addBtn.isHidden = false
            if imageView.image?.size.width == 0 {
                addBtn.setTitle("+", for: .normal)
            } else {
                addBtn.setTitle("REPLACE", for: .normal)
            }
            editBtn.isHidden = true
            if segmentedControl.selectedSegmentIndex == 0 {
                btn1.isHidden = true
                btn2.isHidden = true
                btn3.isHidden = true
            } else {
                btn1.isHidden = false
                btn2.isHidden = false
                btn3.isHidden = false
            }
        } else {
            segmentedControl.isHidden = true
            titleField.isHidden = true
            subtitleField.isHidden = true
            titleLbl.isHidden = false
            subtitleLbl.isHidden = false
            titleLbl.text = patrol.name
            subtitleLbl.text = patrol.desc
            saveBtn.isHidden = true
            addBtn.isHidden = true
            editBtn.isHidden = false
        }
        tableView.reloadData()
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    func queryGroupMembers() {
        groupMembers.removeAll()
        for user in UserService.instance.users {
            if UserService.instance.selectedGroup.dashes.contains(user.dash) && (UserService.instance.selectedGroup.gender == "Both" || UserService.instance.selectedGroup.gender.first == user.gender.first) {
                groupMembers.append(user)
            }
        }
    }
    
    func checkMemberAvailability(user: User) -> Bool {
        var flag = true
        for patrol in UserService.instance.patrols {
            for member in patrol.members {
                if member.id == user.id {
                    flag = false
                    break
                }
            }
        }
        return flag
    }
    func checkMemberBelonging(user: User) -> Bool {
        var flag = false
        if patrol.members != nil {
            for member in patrol.members {
                if member.id == user.id {
                    flag = true
                    break
                }
            }
        }
        return flag
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentlyEditing {
            if segmentedControl.selectedSegmentIndex == 0 {
                return groupMembers.count
            } else {
                if patrol.members != nil {
                    return patrol.members.count
                } else {
                    return 0
                }
            }
        } else {
            if patrol.members != nil {
                return patrol.members.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PatrolMemberCell") as? PrerequisitesCell {
            if segmentedControl.selectedSegmentIndex == 0 {
                if currentlyEditing {
                    cell.setupCell(name: groupMembers[indexPath.row].name,
                                   toggle: checkMemberBelonging(user: groupMembers[indexPath.row]),
                                   editable: checkMemberAvailability(user: groupMembers[indexPath.row]),
                                   togglable: true)
                } else {
                    cell.setupCell(name: patrol.members[indexPath.row].name, toggle: true, editable: false, togglable: false)
                }
            } else {
                // roles
                if patrol.members != nil {
                    let member = patrol.members[indexPath.row]
                    var name = member.name

                    if patrol.chief != nil {
                        if patrol.chief.id == member.id {
                            name = "\(name) (1)"
                        }
                    }
                    if patrol.vice != nil {
                        if patrol.vice.id == member.id {
                            name = "\(name) (2)"
                        }
                    }
                    if patrol.troisieme != nil {
                        if patrol.troisieme.id == member.id {
                            name = "\(name) (3)"
                        }
                    }
                    cell.setupCell(name: name!, toggle: true, editable: false, togglable: false)
                }
            }
            return cell
        }
        return PrerequisitesCell()
    }
    
    @IBAction func onEditClick(_ sender: Any) {
        currentlyEditing = true
        tableView.reloadData()
        setupViews()
    }
    @IBAction func onAddClick(_ sender: Any) {
        
    }
    @IBAction func onSaveClick(_ sender: Any) {
        if titleField.text != "" && patrol.members != nil {
            UserService.instance.updatePatrol(patrol: patrol) { Success in
                self.dismiss(animated: true)
            }
        }
    }
    @IBAction func onbtn1click(_ sender: Any) {
        ctaLbl.isHidden = false
        ctaLbl.text = "Choose who you want to be the Patrol Leader"
    }
    @IBAction func onbtn2click(_ sender: Any) {
        ctaLbl.isHidden = false
        ctaLbl.text = "Choose who you want to be the 1st Helper"
    }
    @IBAction func ontbn3click(_ sender: Any) {
        ctaLbl.isHidden = false
        ctaLbl.text = "Choose who you want to be the 2nd Helper"
    }
    
}
