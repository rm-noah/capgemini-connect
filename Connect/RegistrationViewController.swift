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
    @IBOutlet weak var saveProfileBtn: UIButton!
    
    @IBOutlet weak var formFooterContainer: UIStackView!
    
    private let defaults = UserDefaults.standard
    private var canShowConfirmation = false
    private let emailRegex = "0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        saveProfileBtn.layer.cornerRadius = 12
        // Read UserDefault and populate TextFields here
        let forename: String = defaults.string(forKey: "forename") ?? ""
        let surname: String = defaults.string(forKey: "surname") ?? ""
        let email: String = defaults.string(forKey: "email_address") ?? ""
        
        forenameInput.text = forename
        surnameInput.text = surname
        emailInput.text = email
    }
    
    override func viewDidAppear(_ animated: Bool) {
        canShowConfirmation = true
    }
    
    @IBAction func didFinishEditing(_ sender: Any) {
        print("Finished editing")
    }
    
    @IBAction func clearProfile(_ sender: Any) {
        defaults.set(nil, forKey: "forename")
        defaults.set(nil, forKey: "surname")
        defaults.set(nil, forKey: "email_address")
        defaults.set(nil, forKey: "uuid")
        
        forenameInput.text = ""
        surnameInput.text = ""
        emailInput.text = ""
    }
    
    @IBAction func saveProfile(_ sender: UIButton) {
        animateView(sender)
        let forename: String = forenameInput.text ?? ""
        let surname: String = surnameInput.text ?? ""
        let email: String = emailInput.text ?? ""
        
        if (forename.isEmpty || surname.isEmpty || email.isEmpty) {
            let alert = UIAlertController(title: "Notice", message: "Please complete all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        if (!validateEmail(candidate: email)) {
            let alert = UIAlertController(title: "Notice", message: "Please enter a valid email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
          
        print("All populated, lets go!")
        let uuid = UUID().uuidString
        defaults.set(uuid, forKey: "uuid")
        defaults.set("Noah", forKey: "forename")
        defaults.set("Quinn", forKey: "surname")
        defaults.set("noah.quinn@capgemini.com", forKey: "email_address")
        
        if (canShowConfirmation) {
            let confirmationLabel = UILabel()
            confirmationLabel.textColor = .green
            confirmationLabel.textAlignment = .center
            confirmationLabel.text = "Profile saved successfully"
            formFooterContainer.addArrangedSubview(confirmationLabel)
            canShowConfirmation = false;
        }
    }
    
    @IBAction func hideProfileCreationScreen(_ sender: UIButton) {
        if defaults.string(forKey: "uuid") != nil {
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Notice", message: "Please configure a profile before proceeding to the Scanner", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    private func animateView(_ viewToAnimate:UIView) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
    
    func validateEmail(candidate: String) -> Bool {
     let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
     return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
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
