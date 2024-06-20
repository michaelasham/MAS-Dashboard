//
//  MaterialsVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 25/10/2023.
//

import UIKit

class MaterialsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateMaterials), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        updateMaterials()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMaterials), name: NOTIF_UPDATE_MATERIALS, object: nil)
        
    }
    
    @objc func updateMaterials() {
        addBtn.isHidden = true
        tableView.isHidden = true
        spinner.startAnimating()
        DoablesService.instance.pullMaterials { Success in
            if Success {
                self.tableView.isHidden = false
                self.spinner.isHidden = true
                self.tableView.reloadData()
                self.addBtn.isHidden = false
                self.spinner.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MaterialCell", for: indexPath) as? MaterialCell {
            if indexPath.row + 1 <= DoablesService.instance.materials.count {
                cell.setupCell(material: DoablesService.instance.materials[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DoablesService.instance.selectedMaterial = DoablesService.instance.materials[indexPath.row]
        performSegue(withIdentifier: "toMaterialVC", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DoablesService.instance.materials.count
    }
    
    @IBAction func onAddClick(_ sender: Any) {
        DoablesService.instance.selectedMaterial = Material()
        performSegue(withIdentifier: "toMaterialVC", sender: self)
    }
    

}
