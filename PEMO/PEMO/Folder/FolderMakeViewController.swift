//
//  FolderMakeViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 11. 9..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

class FolderMakeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var foldername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiCustom()
        
        self.foldername.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("슈드리턴")
        self.dismiss(animated: true) {
            //알라모파이어
            //폴더만드는 통신
            //Realm에 추가
            //delegate pattern
        }
        return true
    }
}
extension FolderMakeViewController {
    func uiCustom() {
        self.foldername.becomeFirstResponder()
        self.foldername.setBottomBorder()
        self.foldername.textAlignment = .center
    }
}

