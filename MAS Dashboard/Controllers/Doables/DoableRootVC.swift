//
//  DoableRootVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 19/06/2024.
//

import UIKit

class DoableRootVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    var debounceTimer: Timer?
    let chosenMode = DoablesService.instance.chosenMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateBadges), for: .valueChanged)
        updateBadges()
        pullRequiredData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadges), name: NOTIF_UPDATE_BADGES, object: nil)
    }
    func pullRequiredData() {
        switch chosenMode {
        case "events":
            DoablesService.instance.pullEvents { Success in
                DoablesService.instance.pullBadges { Success in
                    UserService.instance.pullGroups { Success in
                        self.tableView.reloadData()
                    }
                }
            }
        case "materials":
            DoablesService.instance.pullMaterials { Success in
//                print("pulled materials count: \(DoablesService.instance.materials.count)")
                self.tableView.reloadData()
            }
        case "badges":
            DoablesService.instance.pullBadges { Success in
                self.tableView.reloadData()
            }
        default:
            print("nana")
        }
    }
    
    @objc func updateBadges() {
        // Invalidate the previous timer to restart the debounce
        debounceTimer?.invalidate()

        // Start a new timer to delay the execution
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.addBtn.isHidden = true
            DoablesService.instance.pullBadges { success in
                if success {
                    self.tableView.reloadData()
                    self.addBtn.isHidden = false
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath) as? SimpleCell {
            switch chosenMode {
            case "events":
                cell.setupCell(title: DoablesService.instance.events[indexPath.row].title, subtitle: DoablesService.instance.events[indexPath.row].date, active: true)
            case "materials":
                cell.setupCell(title: DoablesService.instance.materials[indexPath.row].name, subtitle: DoablesService.instance.materials[indexPath.row].type, active: DoablesService.instance.materials[indexPath.row].available)
            case "badges":
                cell.setupCell(title: DoablesService.instance.badges[indexPath.row].name!, subtitle: "Last updated on \(DoablesService.instance.badges[indexPath.row].lastUpdated!)", active: DoablesService.instance.badges[indexPath.row].available)
            default:
                print("nana")
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch chosenMode {
        case "events":
            return DoablesService.instance.events.count
        case "materials":
            return DoablesService.instance.materials.count
        case "badges":
            return DoablesService.instance.badges.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch chosenMode {
        case "events":
            DoablesService.instance.selectedEvent = DoablesService.instance.events[indexPath.row]
            performSegue(withIdentifier: "toEventVC", sender: self)
        case "materials":
            DoablesService.instance.selectedMaterial = DoablesService.instance.materials[indexPath.row]
            performSegue(withIdentifier: "toMaterialVC", sender: self)
        case "badges":
            DoablesService.instance.selectedBadge = DoablesService.instance.badges[indexPath.row]
            performSegue(withIdentifier: "toBadgeVC", sender: self)
        default:
            print("nana")
        }

    }
    
    @IBAction func onAddClick(_ sender: Any) {
        switch chosenMode {
        case "events":
            DoablesService.instance.selectedEvent = Event()
            performSegue(withIdentifier: "toEventVC", sender: self)
        case "materials":
            DoablesService.instance.selectedMaterial = Material()
            performSegue(withIdentifier: "toMaterialVC", sender: self)
        case "badges":
            DoablesService.instance.selectedBadge = Badge()
            performSegue(withIdentifier: "toBadgeVC", sender: self)
        default:
            print("nana")
        }
    }


}
