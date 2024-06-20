//
//  GroupsVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 17/12/2023.
//

import UIKit

class GroupsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        spinner.startAnimating()
        addBtn.isHidden = true
        if UserService.instance.groups.count == 0 {
            updateGroups()
        } else {
            self.tableView.reloadData()
            self.spinner.stopAnimating()
            self.addBtn.isHidden = false
            if UserService.instance.groups.count == 1 {
                self.commentLbl.text = "\(UserService.instance.groups.count) Group Available"
            } else {
                self.commentLbl.text = "\(UserService.instance.groups.count) Groups Available"
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateGroups), name: NOTIF_UPDATE_GROUPS, object: nil)
    }
    @objc func updateGroups() {
        
        UserService.instance.pullGroups { Success in
            if Success {
                UserService.instance.pullPatrols { Success in
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                    self.addBtn.isHidden = false
                    if UserService.instance.groups.count == 1 {
                        self.commentLbl.text = "\(UserService.instance.groups.count) Group Available"
                    } else {
                        self.commentLbl.text = "\(UserService.instance.groups.count) Groups Available"
                    }
                }
            }
        }
    }

    @IBAction func onAddClick(_ sender: Any) {
        UserService.instance.selectedGroup = Group()
        performSegue(withIdentifier: "toGroupVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserService.instance.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as? RawUserCell {
            cell.setupCell(name: UserService.instance.groups[indexPath.row].name)
            return cell
        }
        return RawUserCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserService.instance.selectedGroup = UserService.instance.groups[indexPath.row]
        performSegue(withIdentifier: "toGroupVC", sender: self)
    }
}
