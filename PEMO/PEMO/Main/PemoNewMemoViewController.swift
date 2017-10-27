//
//  PemoNewMemoViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 24..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class PemoNewMemoViewController: UIViewController {
    
    var navigationItemTitle: String?
    var navigationItemTitleChange: String?
    var textViewContents: String?
    
    @IBOutlet var inputTitleTextField: UITextField!
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var inputImageView: UIImageView!
    //메모수정 API적용해야함
    @IBAction func editMemo(_ sender: UIBarButtonItem) {
        guard let title = self.inputTitleTextField.text, let content = self.inputTextView.text else { return }
        self.createMemoAlamo(title: title, content: content)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTitleTextField.becomeFirstResponder()
        self.navigationItem.title = self.navigationItemTitle
        self.inputTitleTextField.text = self.navigationItemTitle
        self.inputTextView.text = self.textViewContents
        self.uiCustom()
        self.toolbar()
        self.inputTitleTextField.delegate = self
        self.inputTextView.delegate = self
    }
    // MARK: - FUNC
    //
    func toolbar() {
        // 툴바
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = UIColor.piWhite
        self.inputTextView.inputAccessoryView = toolbar
        // 카메라버튼
        let attachImage = UIBarButtonItem()
        attachImage.title = "IMAGE"
        attachImage.target = self
        attachImage.action = #selector(attachImageButton)
        // Done 버튼
        let done = UIBarButtonItem()
        done.title = "done"
        done.target = self
        done.action = #selector(keyboardDone)
        // flexSpace
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([attachImage, flexSpace, done], animated: true)
    }
    @objc func keyboardDone() {
        self.view.endEditing(true)
    }
    @objc func attachImageButton() {
        //        guard self.uinfo.account != nil else {
        //            self.doLogin(self)
        //            return
        //        }
        // 로그인 안되어 있을경우 로그인창을 띄움
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택하세요", preferredStyle: .actionSheet)
        // 상황에 맞게 Alert이 알맞게 뜸
        // 카메라
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (_) in
                self.imgPicker(.camera)
            }))
        }
        // 저장된앨범
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default, handler: { (_) in
                self.imgPicker(.savedPhotosAlbum)
            }))
        }
        // 포토라이브러리
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토라이브러리", style: .default, handler: { (_) in
                self.imgPicker(.photoLibrary)
            }))
        }
        // 취소버튼
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
extension PemoNewMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 포토라이브러리, 저장된 앨범, 카메라
    //
    func imgPicker(_ source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.inputImageView.image = img
            
        }
        picker.dismiss(animated: true) {
            self.view.endEditing(true)
        }
    }
}

extension PemoNewMemoViewController: UITextViewDelegate, UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let contents = textField.text! as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        self.navigationItemTitleChange = contents.substring(with: NSRange(location: 0, length: length))
        self.navigationItem.title = navigationItemTitleChange
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar
        let ts = TimeInterval(0.1)
        UIView.animate(withDuration: ts) {
            bar?.alpha = (bar?.alpha == 0 ? 1 : 0)
        }
    }

}

// MARK: - Alamofire
//
extension PemoNewMemoViewController {
    func createMemoAlamo(title: String, content: String, category_id: Int = 1) {
        let url = mainDomain + "memo/"
        let parameters: Parameters = ["title":title, "content":content,"category_id":category_id]
        let tokenValue = TokenAuth()
        let headers = tokenValue.getAuthHeaders()
        let call = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
extension PemoNewMemoViewController {
    func uiCustom() {
        self.inputTitleTextField.setBottomBorder()
    }
}
