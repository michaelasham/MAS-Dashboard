//
//  DoableModeratingVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 19/06/2024.
//

import UIKit

class DoableModeratingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onEventsClick(_ sender: Any) {
        DoablesService.instance.chosenMode = "events"
        performSegue(withIdentifier: "toDoableRootVC", sender: self)
    }
    @IBAction func onMaterialsClick(_ sender: Any) {
        DoablesService.instance.chosenMode = "materials"
        performSegue(withIdentifier: "toDoableRootVC", sender: self)
    }
    @IBAction func onBadgesClick(_ sender: Any) {
        DoablesService.instance.chosenMode = "badges"
        performSegue(withIdentifier: "toDoableRootVC", sender: self)
    }

}
