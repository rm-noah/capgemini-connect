//
//  ViewController.swift
//  Connect
//
//  Created by Noah Quinn on 10/12/2020.
//  Copyright © 2020 Noah Quinn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let uuid = defaults.string(forKey: "uuid") {
            print("UUID of profile was \(uuid), directing to Scanner screen")
        } else {
            print("Saved UUID was null, directing user to Registration screen")
            presentRegistrationView()
        }
    }
    
//    func smth() {
//        let defaults = UserDefaults.standard
//        defaults.set("Noah", forKey: "forename")
//        defaults.set("Quinn", forKey: "surname")
//        let forename = defaults.string(forKey: "forename")
//        let surname = defaults.string(forKey: "surname")
//    }
    
//    @IBOutlet weak var field: UITextField!
//    @IBOutlet weak var label: UILabel!
//
//    @IBAction func getVal () {
//         let text: String = field.text ?? ""
//         var multipliedNum: Int = 0
//
//          if let num = Int(text) {
//             multipliedNum = num * 10
//         }
//
//         label.text = "\(multipliedNum)"
//    }
    
    @IBAction func showView() {
        presentRegistrationView()
    }
    
    private func presentRegistrationView() {
        guard let vc = storyboard?.instantiateViewController(identifier: "registration_vc") as? RegistrationViewController else {
            return
        }
        present(vc, animated: true)
    }
}
