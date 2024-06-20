//
//  BadgeActivityVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 18/12/2023.
//

import UIKit

class BadgeActivityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var leaderLbl: UILabel!
    
    var selectedBadge = Badge()
    var selectedLeader = User()
    
    var leaders = UserService.instance.availableLeaders
    var badges = DoablesService.instance.badges
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        button.isHidden = true
        if badges.count == 0 {
            DoablesService.instance.pullBadges { Success in
                if Success {
                    self.badges = DoablesService.instance.badges
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return badges.count
        case 1:
            return leaders.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeActivityDetailCell") as? SimpleCell {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                cell.setupCell(title: badges[indexPath.row].name, subtitle: "Last updated on \(badges[indexPath.row].lastUpdated)", active: true)
            case 1:
                cell.setupCell(title: leaders[indexPath.row].name, subtitle: leaders[indexPath.row].mobile, active: true)
            default:
                return SimpleCell()
            }
            return cell
        }
        return SimpleCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            selectedBadge = badges[indexPath.row]
            titleLbl.text = "Badge: \(selectedBadge.name!)"
            button.isHidden = false
        case 1:
            selectedLeader = leaders[indexPath.row]
            leaderLbl.text = "Leader: \(selectedLeader.name!)"
        default:
            print("hamada")
        }
    }
    
    @IBAction func onSegmentChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func onSaveClick(_ sender: Any) {
        DoablesService.instance.createBadgeActivity(badge: selectedBadge, winner: UserService.instance.selectedUser, leader: selectedLeader, timestamp: "unknown") { Success in
            if Success {
                self.dismiss(animated: true)
            }
        }
    }
    
}
