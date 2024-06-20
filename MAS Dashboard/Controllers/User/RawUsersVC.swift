//
//  RawUsersVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 10/12/2023.
//

import UIKit

class RawUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {


    
    @IBOutlet weak var convertBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        FirebaseService.instance.pullUsers { Success in
//            FirebaseService.instance.fixGender()
//        }
        UserService.instance.pullRawUsers { Success in
            if Success {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RawUserCell") as? RawUserCell {
            cell.setupCell(name: UserService.instance.rawUsers[indexPath.row].name)
            return cell
        }
        return RawUserCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserService.instance.rawUsers.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserService.instance.selectedRawUser = UserService.instance.rawUsers[indexPath.row]
        performSegue(withIdentifier: "toRawUserVC", sender: self)
    }
    @IBAction func onConvertClick(_ sender: Any) {
        if UserService.instance.rawUsers.count > 0 {
            UserService.instance.convertUsers { Success in
                UserService.instance.uploadUsers { Success in
                    if Success {
                        self.convertBtn.setTitle("☑️", for: .normal)
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            self.convertBtn.setTitle("👀", for: .normal)
        }
    }
}
