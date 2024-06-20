//
//  RawUserVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 10/12/2023.
//

import UIKit

class RawUserVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let raw = UserService.instance.selectedRawUser
        var text = raw.name
        if let leader = raw.leader {
            text = (text ?? "") + " " + leader
        }
        if let dob = raw.dateOfBirth {
            text = (text ?? "") + " " + dob
        }
        if let comments = raw.comments {
            text = (text ?? "") + " " + comments
        }
        if let mobile = raw.mobile {
            text = (text ?? "") + " " + mobile
        }
        if let flag = raw.flag {
            text = (text ?? "") + " " + flag
        }
        if let source = raw.source {
            text = (text ?? "") + " " + source
        }
        if let year = raw.year {
            text = (text ?? "") + " " + String(year)
        }
        textView.text = text
        // Do any additional setup after loading the view.
    }

}
