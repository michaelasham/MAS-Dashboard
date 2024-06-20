//
//  UserModeratingVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 19/06/2024.
//

import UIKit

class UserModeratingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func OnUsersClick(_ sender: Any) {
        UserService.instance.chosenMode = "users"
        performSegue(withIdentifier: "toUserRootVC", sender: self)
    }
    @IBAction func OnRawUsersClick(_ sender: Any) {
        UserService.instance.chosenMode = "rawUsers"
        performSegue(withIdentifier: "toUserRootVC", sender: self)
    }
    @IBAction func OnGroupsClick(_ sender: Any) {
        UserService.instance.chosenMode = "groups"
        performSegue(withIdentifier: "toUserRootVC", sender: self)
    }
    @IBAction func onDashesClick(_ sender: Any) {
        UserService.instance.chosenMode = "dashes"
        performSegue(withIdentifier: "toUserRootVC", sender: self)
    }

}
