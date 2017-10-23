//
//  PemoLoginViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster

class PemoLoginViewController: UIViewController {

    // MARK: - @IB
    //
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginFacebookButton: UIButton!
    
    @IBAction func login(_ sender: UIButton) {
        print("로그인")
        Toast(text: "로그인실패").show()
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
    }
    @IBAction func loginFacebook(_ sender: UIButton) {
        
    }
    @IBAction func createAnAccount(_ sender: UIButton) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "JOIN") as? PemoJoinViewController else { return }
        emailTextField.text = ""
        passwordTextField.text = ""
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiCustom()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.emailTextField.becomeFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
// MARK: - Alamofire
//
extension PemoLoginViewController {
    func login(email: String, password:String) {
        
    }
}
// MARK: - UITextFieldDelegate
//
extension PemoLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEqual(self.emailTextField)) {
            self.passwordTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.passwordTextField)) {
            self.login(loginButton)
        }
        return true
    }
}
// MARK: - UI
//
extension PemoLoginViewController {
    func uiCustom() {
        emailTextField.becomeFirstResponder()
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginFacebookButton.layer.cornerRadius = 10
        loginFacebookButton.layer.masksToBounds = true
    }
}
