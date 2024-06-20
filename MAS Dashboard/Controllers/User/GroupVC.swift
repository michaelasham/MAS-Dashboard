//
//  GroupVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 17/12/2023.
//

import UIKit

class GroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let group = UserService.instance.selectedGroup
    var members = [User]()
    var patrols = [Patrol]()
    
    let types = ["Males", "Females", "Both"]
    var selectedType = "Males"
    
    var chosenDashes = [Int]()
    
    
    var currentlyEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        selectGender()
        UserService.instance.queryLeaders()
        UserService.instance.queryAvailableDashes()
        queryGroupPatrols()
        
        addBtn.isHidden = true
        if group.id == nil {
            //new
            pickerView.isUserInteractionEnabled = true
            currentlyEditing = true
            titleField.isHidden = false
            nameLbl.isHidden = true
            editBtn.isHidden = true
            saveBtn.isHidden = false
        } else {
            //old
            pickerView.isUserInteractionEnabled = false
            chosenDashes = group.dashes
            queryGroupMembers()
            nameLbl.text = group.name
            titleField.isHidden = true
            nameLbl.isHidden = false
            editBtn.isHidden = false
            saveBtn.isHidden = true
        }
        commentLbl.text = "\(chosenDashes.count) selected out of \(UserService.instance.availableDashes.count) Dashes"
        NotificationCenter.default.addObserver(self, selector: #selector(onSwitchClick), name: NOTIF_SWITCH_CLICK, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(queryGroupPatrols), name: NOTIF_UPDATE_PATROLS, object: nil)
    }

    
    @objc func onSwitchClick() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            chosenDashes.removeAll()
            for i in 0...(UserService.instance.availableDashes.count - 1) {
                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PrerequisitesCell {
                    if cell.toggleSwitch.isOn {
                        chosenDashes.append(UserService.instance.availableDashes[i])
                        commentLbl.text = "\(chosenDashes.count) selected out of \(UserService.instance.availableDashes.count) Dashes"
                        queryGroupMembers()
                    }
                }
            }
        case 2:
            print("lego")

        case 3:
            print("lego")

        default:
            print("lego")
        }
    }
    
    func queryGroupMembers() {
        members.removeAll()
        for user in UserService.instance.users {
            if chosenDashes.contains(user.dash) && (selectedType == "Both" || selectedType.first as? String == user.gender.first as? String) {
                members.append(user)
            }
        }
    }
    
    @objc func queryGroupPatrols() {
        patrols.removeAll()
        for patrol in UserService.instance.patrols {
            if patrol.group.id == group.id {
                patrols.append(patrol)
            }
        }
    }
    
    @IBAction func onEditClick(_ sender: Any) {
        pickerView.isUserInteractionEnabled = true
        currentlyEditing = true
        titleField.isHidden = false
        nameLbl.isHidden = true
        editBtn.isHidden = true
        saveBtn.isHidden = false
        titleField.text = group.name
        tableView.reloadData()
    }
    

    @IBAction func onSaveClick(_ sender: Any) {
        if titleField.text != "" {
            var leadersList = [User]()
            var patrolsList = [Patrol]()
            
            UserService.instance.updateGroup(name: titleField.text!, dashes: chosenDashes, gender: selectedType, leaders: leadersList, patrols: patrolsList) { Success in
                if Success {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    @IBAction func onAddClick(_ sender: Any) {
        UserService.instance.selectedPatrol = Patrol()
        performSegue(withIdentifier: "toPatrolVC", sender: self)
    }
    
    @IBAction func onSegmentControl(_ sender: Any) {
        tableView.reloadData()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            addBtn.isHidden = true
            commentLbl.text = "\(chosenDashes.count) selected out of \(UserService.instance.availableDashes.count) Dashes"
        case 1:
            addBtn.isHidden = true

        case 2:
            addBtn.isHidden = true
            commentLbl.text = "\(members.count) Members"
        case 3:
            addBtn.isHidden = false
            commentLbl.text = "\(patrols.count) Available Patrols."
            if patrols.count == 1 {
                commentLbl.text = "\(patrols.count) Available Patrol."
            }
        default:
            print("habeeby")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            //dashes
            if currentlyEditing {
                //all available dashes
                return UserService.instance.availableDashes.count
            } else {
                //just group dashes
                return chosenDashes.count
            }
        case 1:
            //leaders
            if currentlyEditing {
                //all leaders
                return UserService.instance.availableLeaders.count
            } else {
                //just group leaders
                if group.leaders != nil {
                    return group.leaders.count
                }
            }
        case 2:
            //members
            return members.count
        case 3:
            //patrols
            return patrols.count
        default:
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupDetailCell") as? PrerequisitesCell {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                //dashes
                if !currentlyEditing {
                    // just group dashes
                    cell.setupCell(name: "\(chosenDashes[indexPath.row])-DASH", toggle: true, editable: false, togglable: false)
                } else {
                    // all dashes
                    var toggle = false
                    if chosenDashes.contains(UserService.instance.availableDashes[indexPath.row]) {
                        toggle = true
                    }
                    let dash = UserService.instance.availableDashes[indexPath.row]
                    cell.setupCell(name: "\(dash)-DASH", toggle: toggle, editable: isDashAvailable(dash: dash, gender: selectedType), togglable: true)
                }

            case 1:
                //leaders
                if currentlyEditing {
                    //all leaders
                    var toggle = false
                    for leader in group.leaders {
                        if UserService.instance.availableLeaders[indexPath.row].id == leader.id {
                            toggle = true
                            break
                        }
                    }
                    cell.setupCell(name: UserService.instance.availableLeaders[indexPath.row].name, toggle: toggle, editable: currentlyEditing, togglable: true)
                } else {
                    //just group leaders
                    cell.setupCell(name: group.leaders[indexPath.row].name, toggle: true, editable: currentlyEditing, togglable: false)
                }
            case 2:
                //members (non-editable)
                cell.setupCell(name: members[indexPath.row].name, toggle: true, editable: false, togglable: false)
            case 3:
                //patrols
                cell.setupCell(name: patrols[indexPath.row].name, toggle: patrols[indexPath.row].active, editable: currentlyEditing, togglable: true)
            default:
                return cell
            }
            return cell
        }
        return PrerequisitesCell()
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            //dashes
//        case 1:
//            //leaders
//        case 2:
//            //members (non-editable)
//        case 3:
//            //patrols
//
//        default:
//            print("hamada")
//        }
//    }

}

extension GroupVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        types[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tableView.reloadData()
        selectedType = types[row]
    }
    func selectGender() {
        if let type = group.gender {
            selectedType = type
            var i = 0
            switch type {
            case "Males":
                i = 0
            case "Females":
                i = 1
            default:
                i = 2
            }
            pickerView.selectRow(i, inComponent: 0, animated: true)
        }
    }
    func isDashAvailable(dash: Int, gender: String) -> Bool {
        var flag = true
        for group in UserService.instance.groups {
            if (group.dashes.contains(dash) && group.id != self.group.id) && (group.gender == gender || group.gender == "Both" || gender == "Both") {
                flag = false
                break
            }
        }
        return flag
    }
}
