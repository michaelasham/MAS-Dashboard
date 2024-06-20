//
//  ViewController.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 23/10/2023.
//

import UIKit

class BadgesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {



    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    var debounceTimer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateBadges), for: .valueChanged)
        updateBadges()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadges), name: NOTIF_UPDATE_BADGES, object: nil)

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

    
}

