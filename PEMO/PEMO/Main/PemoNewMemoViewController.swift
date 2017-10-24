//
//  PemoNewMemoViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 24..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import KUIPopOver

class PemoNewMemoViewController: UIViewController, KUIPopOverUsable {

    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var inputImageView: UIImageView!
    
    // MARK: - KUIPopOver
    //
    var contentSize: CGSize {
        return CGSize(width: 360.0, height: 600.0)
    }
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbar()
    }
    // MARK: - FUNC
    //
    func toolbar() {
        // 툴바
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = UIColor.white
        self.inputTextView.inputAccessoryView = toolbar
        // 버튼
        let attachImage = UIBarButtonItem()
        attachImage.title = "IMAGE"
        attachImage.target = self
        attachImage.action = #selector(attachImageButton)
        
        // flexSpace
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //        let xxx = UIBarButtonItem()
        //        let yyy = UIImageView()
        //        xxx.image = self.inputImage.image
        //        xxx.customView?.addSubview(yyy)
        toolbar.setItems([flexSpace, attachImage, flexSpace], animated: true)
        //self.view.endEdition(true)
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
