//
//  PemoJoinViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

class PemoJoinViewController: UIViewController {

    // MARK: - @IB
    //
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet var joinButton: UIButton!
    @IBAction func join(_ sender: UIButton) {
        print("조인")
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
//        passwordConfirmTextField.resignFirstResponder()
    }
    @IBAction func popViewController(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
        self.uiCustom()
    }

    // MARK: - FUNC
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmTextField.resignFirstResponder()
    }
    
}
extension PemoJoinViewController {
    func uiCustom() {
        emailTextField.becomeFirstResponder()
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordConfirmTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        joinButton.layer.cornerRadius = 10
        joinButton.layer.masksToBounds = true
    }
}
extension PemoJoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEqual(self.emailTextField)) {
            self.passwordTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.passwordTextField)) {
            self.passwordConfirmTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.passwordConfirmTextField)) {
            self.join(joinButton)
        }
        return true
    }
}
