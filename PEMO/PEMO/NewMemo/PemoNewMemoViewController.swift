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

enum WriteType {
    case new
    case edit
}

class PemoNewMemoViewController: UIViewController {
    
    var subject: String? // 실시간 제목
    lazy var memoDao = MemoDAO()
    
    var memoTransfer: MemoData?
    var writeType: WriteType = .new
    
    @IBOutlet var inputTitleTextField: UITextField!
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var inputImageView: UIImageView!
    @IBAction func cancelWrite(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func editMemo(_ sender: UIBarButtonItem) {
        switch self.writeType {
        case .new:
            let data = MemoData()
//            data.id = 
            data.title = self.subject
            data.content = self.inputTextView.text
//            data.image =

//            data.created_date = Date()
//            data.modified_date = Date()
            self.memoDao.insert(data)
//            guard let title = self.subject, let content = self.inputTextView.text else {
//                print("가드렛")
//                return
//            }
//            self.writeMemoAlamo(title: title, content: content, method: .post)
        case .edit:
            let data = MemoData()
            data.title = self.subject
            data.content = self.inputTextView.text
            //            data.image =
//            data.created_date = Date()
//            data.modified_date = Date()

            self.memoDao.insert(data)
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.memoDataList.append(data)
//            print("EDITEDIT")
//            guard let title = self.memoTransfer?.title, let content = self.inputTextView.text else {
//                print("가드렛")
//                return
//            }
//            self.writeMemoAlamo(title: title, content: content, method: .post)//patch로 바꾸기
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiCustom()
        self.toolbar()
        self.inputTextView.delegate = self
        
        switch self.writeType {
        case .new:
            inputTextView.text = "WRITING..."
            inputTextView.textColor = .lightGray
        case .edit:
            self.navigationItem.title = self.memoTransfer?.title
            self.inputTextView.text = self.memoTransfer?.content
        }

        
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
        attachImage.image = UIImage(named: "instagram.png")
//        attachImage.tintColor = UIColor.clear
        attachImage.target = self
        attachImage.action = #selector(attachImageButton)
        // Done 버튼
        let done = UIBarButtonItem()
        done.image = UIImage(named: "check.png")
//        done.tintColor = UIColor.clear
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
// MARK: - UITextViewDelegate
//
extension PemoNewMemoViewController: UITextViewDelegate {
    // 텍스트뷰의 첫 15자를 메모의 title로 함
    // 텍스트뷰의 첫 15자가 해당 뷰의 네비게이션바 타이틀로 표시됨
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        self.navigationItem.title = subject
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch self.writeType {
        case .new:
            if textView.text == "WRITING..." {
                textView.text = ""
                textView.textColor = UIColor.black
            }
            textView.becomeFirstResponder()
        default:
            print("통과")
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch self.writeType {
        case .new:
            if textView.text == "" {
                textView.text =  "WRITING..."
                textView.textColor = UIColor.lightGray
            }
            textView.resignFirstResponder()
        default:
            print("통과")
        }
    }
}

// MARK: - Alamofire
//
extension PemoNewMemoViewController {
    func writeMemoAlamo(title: String, content: String, method: HTTPMethod, category_id: Int = 1) {
        print("알라모")
        let url = mainDomain + "memo/"
        let parameters: Parameters = ["title":title, "content":content,"category_id":category_id]
        let tokenValue = TokenAuth()
        let headers = tokenValue.getAuthHeaders()
        let call = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
        self.inputTextView.layer.cornerRadius = 5
    }
}
