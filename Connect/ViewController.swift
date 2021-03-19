//
//  ViewController.swift
//  Connect
//
//  Created by Noah Quinn on 10/12/2020.
//  Copyright © 2020 Noah Quinn. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let checkInEndpoint: String = "https://cm7oikm6cl.execute-api.eu-central-1.amazonaws.com/default/CheckInUser"
    
    @IBOutlet weak var mainStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.failed()
                return
            }
            let avVideoInput: AVCaptureDeviceInput
            
            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.failed()
                return
            }
            
            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                self.failed()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            } else {
                self.failed()
                return
            }
            
            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.avPreviewLayer)
            self.avCaptureSession.startRunning()
            
            self.view.bringSubviewToFront(self.mainStack)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            avCaptureSession.startRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    func validateQRCode(code: String) -> Bool {
        let codeRegex = "^((\\w)+-{1})+\\d+$"
        return NSPredicate(format: "SELF MATCHES %@", codeRegex).evaluate(with: code)
    }
    
    @IBAction func showView() {
        presentRegistrationView()
    }
    
    private func presentRegistrationView() {
        guard let vc = storyboard?.instantiateViewController(identifier: "registration_vc") as? RegistrationViewController else {
            return
        }
        present(vc, animated: true)
    }
    
    func found(code: String) {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 21, to: today)
        
        guard let url = URL(string: checkInEndpoint) else {
            print("CheckIn Endpoint invalid")
            return
        }
        
        let defaults = UserDefaults.standard
        let email: String? = defaults.string(forKey: "email_address") ?? nil
        let surname: String? = defaults.string(forKey: "surname") ?? nil
        
        if (email == nil) {
            let ac = UIAlertController(title: "Invalid Profile Configuration", message: "Check your profile contains all necessary information", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Close", style: .default))
            present(ac, animated: true)
            return
        }
        
        
        let parameters: [String: Any?] = [
            "uuid": UUID().uuidString,
            "timestamp": tomorrow?.timeIntervalSince1970,
            "email": email,
            "location": code,
            "surname": surname
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let httpbody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpbody;
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let response = response else {
                print("Cannot found the response")
                return
            }
    
            let myResponse = response as! HTTPURLResponse
            print("Response code: ", myResponse.statusCode)
            
            if (myResponse.statusCode == 201) {
                DispatchQueue.main.async { () -> Void in
                    let ac = UIAlertController(title: "Signed in", message: "Successfully registered attendance", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Close", style: .default))
                    self.present(ac, animated: true)
                }
            } else {
                DispatchQueue.main.async { () -> Void in
                    let ac = UIAlertController(title: "Failed to Sign-In", message: "An unexpected error occurred", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Close", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }.resume()
    }
}


extension ViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        avCaptureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if  (self.validateQRCode(code: stringValue)) {
                found(code: stringValue)
            } else {
                let ac = UIAlertController(title: "Failed to Sign-In", message: "The code was not as expected", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Close", style: .default))
                self.present(ac, animated: true)
            }
        }
        
        avCaptureSession.startRunning()
    }
}
