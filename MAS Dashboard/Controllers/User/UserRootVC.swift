//
//  UserRootVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 16/12/2023.
//

import UIKit

class UserRootVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var filteredUsers = [User]()
    var filteredRawUsers = [RawUser]()
    var filteredGroups = [Group]()
    var filteredDashes = [Int]()

    let chosenMode = UserService.instance.chosenMode
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        spinner.isHidden = false
        spinner.startAnimating()
        pullRequiredData()
    }
    
    func pullRequiredData() {
        switch chosenMode {
        case "users":
            UserService.instance.pullUsers { Success in
                if Success {
                        DoablesService.instance.pullBadges { Success in
                            if Success {
                                self.pullBadgeActivities()
                                self.tableView.reloadData()
                                self.spinner.stopAnimating()
                            }
                        }
                }
            }
        case "rawUsers":
            UserService.instance.pullRawUsers { Success in
                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }
        case "groups":
            UserService.instance.pullGroups { Success in
                UserService.instance.pullPatrols { Success in
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                }
            }
        case "dashes":
            //wait
            UserService.instance.pullUsers { Success in
                UserService.instance.queryAvailableDashes()
                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }
            print("nana")
        default:
            print("nana")
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.2) {
            self.view.superview!.endEditing(true)
            self.view.superview!.frame.origin.y = 0
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch chosenMode {
        case "users":
            if let searchText = searchBar.text {
                filteredUsers = UserService.instance.users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
            }
        case "rawUsers":
            if let searchText = searchBar.text {
                filteredRawUsers = UserService.instance.rawUsers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
            }
        case "groups":
            if let searchText = searchBar.text {
                filteredGroups = UserService.instance.groups.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
            }
        case "dashes":
            //wait
            print("nana")
        default:
            print("nana")
        }

    }

    func pullBadgeActivities() {
        DoablesService.instance.pullBadgeActivities { Success in
            UserService.instance.pullGroups { Success in
                if Success {
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch chosenMode {
        case "users":
            if searchBar.text?.count ?? 0 > 0{
                return filteredUsers.count
            } else {
                return UserService.instance.users.count
            }
        case "rawUsers":
            if searchBar.text?.count ?? 0 > 0{
                return filteredRawUsers.count
            } else {
                return UserService.instance.rawUsers.count
            }
        case "groups":
            if searchBar.text?.count ?? 0 > 0{
                return filteredGroups.count
            } else {
                return UserService.instance.groups.count
            }
        case "dashes":
            //wait
            print("nana")
            return UserService.instance.availableDashes.count
        default:
            print("nana")
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell") as? SimpleCell {
        switch chosenMode {
        case "users":
            if searchBar.text?.count ?? 0 > 0{
                cell.setupCell(title: filteredUsers[indexPath.row].name, subtitle: filteredUsers[indexPath.row].mobile, active: true)
            } else {
                cell.setupCell(title: UserService.instance.users[indexPath.row].name, subtitle: UserService.instance.users[indexPath.row].mobile, active: true)
            }
        case "rawUsers":
            if searchBar.text?.count ?? 0 > 0{
                cell.setupCell(title: filteredRawUsers[indexPath.row].name, subtitle: filteredRawUsers[indexPath.row].mobile, active: true)
            } else {
                cell.setupCell(title: UserService.instance.rawUsers[indexPath.row].name, subtitle: UserService.instance.rawUsers[indexPath.row].mobile, active: true)
            }
        case "groups":
            if searchBar.text?.count ?? 0 > 0{
                cell.setupCell(title: filteredGroups[indexPath.row].name, subtitle: filteredGroups[indexPath.row].gender, active: true)
            } else {
                cell.setupCell(title: UserService.instance.groups[indexPath.row].name, subtitle: UserService.instance.groups[indexPath.row].gender, active: true)
            }
        case "dashes":
            //wait
            print("nana")
            cell.setupCell(title: "\(UserService.instance.availableDashes[indexPath.row])-DASH", subtitle: "", active: true)
        default:
            print("nana")
        }
        return cell
        }
        return SimpleCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch chosenMode {
        case "users":
            UserService.instance.selectedUser = UserService.instance.users[indexPath.row]
            performSegue(withIdentifier: "toUserVC", sender: self)
        case "rawUsers":
            UserService.instance.selectedRawUser = UserService.instance.rawUsers[indexPath.row]
            performSegue(withIdentifier: "toRawUserVC", sender: self)
        case "groups":
            UserService.instance.selectedGroup = UserService.instance.groups[indexPath.row]
            performSegue(withIdentifier: "toGroupVC", sender: self)
        case "dashes":
            //wait
            print("nana")
        default:
            print("nana")
        }

    }


}
