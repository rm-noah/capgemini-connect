//
//  RegistrationViewController.swift
//  Connect
//
//  Created by Noah Quinn on 15/12/2020.
//  Copyright © 2020 Noah Quinn. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var forenameInput: UITextField!
    @IBOutlet weak var surnameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Read UserDefault and populate TextFields here
    }
    
    @IBAction func didFinishEditing(_ sender: Any) {
        print("Finished editing")
    }
    
    @IBAction func saveConfiguration() {
        let forename = forenameInput.text
        let surname = surnameInput.text
        let email = emailInput.text
        
        if [forename, surname, email].atleastOneNil() {
            
        }
        
        let defaults = UserDefaults.standard
        let uuid = UUID().uuidString
        defaults.set(uuid, forKey: "uuid")
        defaults.set("Noah", forKey: "forename")
        defaults.set("Quinn", forKey: "surname")
        defaults.set("noah.quinn@capgemini.com", forKey: "email_address")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
