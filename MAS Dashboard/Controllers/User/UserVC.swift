//
//  UserVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 16/12/2023.
//

import UIKit

class UserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mobileBtn: UIButton!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    
    let user = UserService.instance.selectedUser
    var badgeActivities = [BadgeActivity]()
    var group = Group()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        nameLbl.text = user.name
        subtitleLbl.text = "\(user.dash!)-Dash"
        mobileBtn.setTitle("+20 \(user.mobile!)", for: .normal)
        queryOurBadgeActivities()
        queryUserGroup()
    }

    func queryUserGroup() {
        for agroup in UserService.instance.groups {
            if agroup.dashes.contains(user.dash!) && (agroup.gender == "Both" || agroup.gender.first == user.gender.first) {
                group = agroup
                groupLbl.text = "Current Group: \(group.name ?? "Unassigned")"
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return user.comments?.count ?? 0
        } else {
            // 0
            return badgeActivities.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeActivityCell", for: indexPath) as? BadgeActivityCell {
            if segmentedControl.selectedSegmentIndex == 1 {
                //comment
                cell.setupComment(comment: user.comments?[indexPath.row] ?? Comment())
            } else {
                // badge
                cell.setupBadge(badge: badgeActivities[indexPath.row])
            }
            return cell
        }

        return BadgeActivityCell()
    }
    
    @IBAction func onMobileClick(_ sender: Any) {
        
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 1 {
            addBtn.isHidden = true
        } else {
            addBtn.isHidden = false
        }
        tableView.reloadData()
    }
    @IBAction func onAddClick(_ sender: Any) {
        performSegue(withIdentifier: "toBadgeActivityVC", sender: self)
    }
    
    func queryOurBadgeActivities() {
        badgeActivities.removeAll()
        for activity in DoablesService.instance.badgeActivities {
            if activity.winner.id == UserService.instance.selectedUser.id {
                badgeActivities.append(activity)
            }
        }
        tableView.reloadData()
    }
}
