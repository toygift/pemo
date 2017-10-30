//
//  PemoJoinViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster

// MARK: - UserType
//
enum UserType: String {
    case normal = "normal"
    case facebook = "facebook"
}

class PemoJoinViewController: UIViewController {

    // MARK: - var/let
    //
    var access_key: Bool = false // 페이스북로그인시 true
  
    // MARK: - @IB
    //
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet var joinButton: UIButton!
    @IBAction func join(_ sender: UIButton) {
        print("########################## 회원가입 버튼 클릭 ##########################")
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmTextField.resignFirstResponder()

        if (self.emailTextField.text?.isEmpty)! {
            Toast(text: "이메일을 입력해주세요").show()
        } else if self.emailCheck(withEmail: self.emailTextField.text!) == false {
            Toast(text: "잘못된 이메일 형식입니다").show()
        } else if (passwordTextField.text?.count)! < 8 {
            Toast(text: "패스워드는 8자 이상입니다").show()
        } else if (passwordTextField.text?.isEmpty)! || (passwordConfirmTextField.text?.isEmpty)! {
            Toast(text: "패스워드를 모두 입력해주세요").show()
        } else if passwordTextField.text != passwordConfirmTextField.text {
            Toast(text: "패스워드를 확인해주세요").show()
        } else {
            guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }
            self.joinWithAlamo(email: email, password: password, user_type: UserType.normal.rawValue)
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    // MARK: - 이메일정규식
    //
    func emailCheck(withEmail: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: withEmail)
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
/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/
// MARK: - UITextFieldDelegate
//
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

// MARK: - 서버통신 (Alamofire)
//
extension PemoJoinViewController {
    func joinWithAlamo(email: String, password: String, user_type:String) {
        print("########################## 알라모파이어 진입 ##########################")
        let url = mainDomain + "user/"
        let parameters: Parameters = ["username":email, "password":password, "user_type":user_type]
        
        let call = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
        call.validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                print("########################## 리스폰스 성공 ##########################")
//                if !json["username"].arrayValue.isEmpty {
//                    Toast(text: "이미 존재하는 이메일 입니다").show()
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
                
            case .failure(let error):
                print(error)
                print("########################## 리스폰스 실패 ##########################")
                Toast(text: "이미 존재하는 이메일 입니다").show()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
// MARK: - uiCustom
// 항상 마지막으로
extension PemoJoinViewController {
    func uiCustom() {
        emailTextField.becomeFirstResponder()
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        passwordConfirmTextField.setBottomBorder()
        joinButton.layer.cornerRadius = 10
        joinButton.layer.masksToBounds = true
    }
}
