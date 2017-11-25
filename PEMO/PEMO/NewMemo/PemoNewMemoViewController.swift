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
import Toaster
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper
import ObjectMapper_Realm
import KUIPopOver
import Kingfisher

enum WriteType {
    case new
    case edit
}


class PemoNewMemoViewController: UIViewController, PemoFolderCollectionViewControllerDelegate {
    func dismiss(with: PemoFolderCollectionViewController) {
        print("dismiss delegate")
    }
    
    
    
    var selectFolder: Int?
    var selectedFolder: Folder!
    private var realm: Realm!
    private var folders: Results<Folder>!
    private var token: NotificationToken!
    private var memos: Results<MemoData>!
    var subject: String? // 실시간 제목
    //    lazy var memoDao = MemoDAO()
    
    var memoTransfer: MemoData?
    var memoPkTransfer: Int!
    var writeType: WriteType = .new
    var transferIndexPath: Results<Folder>!
    var selectedImage: UIImage?
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var foldername: UILabel!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var inputImageView: UIImageView!
    @IBAction func cancelWrite(_ sender: UIButton) {
        if writeType == .new {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func selectFolderwithMemo(_ sender: UIButton) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NAVIFOLDERs") as? PemoFolderCollectionViewController else { return }
        nextViewController.popOverType = PopOver.writeFolder
        nextViewController.delegate = self
        nextViewController.showPopover(withNavigationController: sender, sourceRect: sender.bounds)
        
    }
    @IBAction func editMemo(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        //        updateAndAdd()
        //        print("버튼 터치치치치")
    }
    func updateAndAdd() {
        if self.writeType == .edit {
            
            //            do {
            guard let title = self.subject , let content = self.inputTextView.text else { return }
            self.writeMemoAlamo(title: title, content: content, method: .patch, writeType: .edit)
            print("edit")
            self.navigationController?.popViewController(animated: true)
        } else {
            //메모생성
            let newMemo = MemoData()
            newMemo.title = self.subject
            newMemo.content = self.inputTextView.text
            guard let title = self.subject, let content = self.inputTextView.text, let category = self.selectFolder else { return }
            print("메모생성")
            //이미지없을경우?
            
            
            if self.selectFolder != 0 {
                self.writeMemoAlamo(title: title, content: content, method: .post, writeType: .new, category_id: category)
            } else {
                self.writeMemoAlamo(title: title, content: content, method: .post, writeType: .new)
            }
            
            
            print("new")
            self.selectFolder = 0
            self.dismiss(animated: true, completion: nil)
        }
        print("if문 나옴")
        //        self.navigationController?.popViewController(animated: true)
        
    }
    func alamo2(with: PemoFolderCollectionViewController, indexPath: IndexPath) {
        print("Delegate 넘오옴")
        self.selectFolder = self.folders[indexPath.item].id
        self.foldername.text = self.folders[indexPath.item].title
    }
    /**********************************************************************************************************************************************************/
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        
        self.uiCustom()
        self.toolbar()
        self.inputTextView.delegate = self
        self.folders = realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: true)
        switch self.writeType {
        case .new:
            inputTextView.text = "WRITING..."
            inputTextView.textColor = .lightGray
        case .edit:
            
            if memoTransfer?.image != nil {
                let tempimage = UIImageView()
                var tempimager : UIImage!
                guard let path = self.memoTransfer?.image else { return }
                //            if let imageURL = URL(string: path) {
                let imageURL = URL(string: path)
                
                tempimage.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receive, total) in
                    //                print("\(indexPath.row + 1) : \(receive)/\(total)")
                }, completionHandler: { (image, error, cacheType, imageURL) in
                    tempimager = image
                })
                
                let attributedStringTextAttachment = NSTextAttachment()
                attributedStringTextAttachment.image = tempimager//UIImage(named: "launch2")
                let attributedString = NSMutableAttributedString(string: (self.memoTransfer?.content)!)
//                attributedString.addAttribute(NSAttributedStringKey.font, value:UIFont(name:"Helvetica", size:18.0)!, range:NSMakeRange(0,35))
//                attributedString.addAttribute(NSAttributedStringKey.attachment, value:attributedStringTextAttachment, range:NSMakeRange(0,1))
                let attrStringWithImage = NSAttributedString(attachment: attributedStringTextAttachment)
                attributedString.append(attrStringWithImage)
                inputTextView.attributedText = attributedString
                
                
            } else {
                inputTextView.text = self.memoTransfer?.content
            }
////            attributedStringTextAttachment.image = UIImage(named: "launch2")
//            let attributedString = NSMutableAttributedString(string: (self.memoTransfer?.content)!)
////            let textAttachment = NSTextAttachment()
////            textAttachment.image = UIImage(named: "launch2")
////
////            let oldWidth = textAttachment.image!.size.width;
//            
//            //I'm subtracting 10px to make the image display nicely, accounting
//            //for the padding inside the textView
//            
////            let scaleFactor = oldWidth / (txtBody.frame.size.width - 10);
////            textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
//            let attrStringWithImage = NSAttributedString(attachment: attributedStringTextAttachment)
//            attributedString.append(attrStringWithImage)
//            inputTextView.attributedText = attributedString
            
            
            
            
//            let attributedString = NSMutableAttributedString(string: (self.memoTransfer?.content)!)
//
////            attributedString.addAttribute(NSAttributedStringKey.font, value:UIFont(name:"Helvetica", size:12.0)!, range:NSMakeRange(0,35))
//            attributedString.addAttribute(NSAttributedStringKey.attachment, value:attributedStringTextAttachment, range:NSMakeRange(0,1))
//
//
//            inputTextView.attributedText = attributedString
            //Uncomment the line below and set the frame of the text view.
            //textView.frame = CGRect.init(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
            
            
            
            self.navigationItem.title = self.memoTransfer?.title
//            self.inputTextView.text = self.memoTransfer?.content
//            if memoTransfer?.image != nil {
//                
//                guard let path = self.memoTransfer?.image else { return }
//                //            if let imageURL = URL(string: path) {
//                let imageURL = URL(string: path)
//                inputImageView.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receive, total) in
//                    //                print("\(indexPath.row + 1) : \(receive)/\(total)")
//                }, completionHandler: { (image, error, cacheType, imageURL) in
//                    //                print("\(indexPath.row + 1) : Finished")
//                })
//             
//            } else {
//                inputImageView.isHidden = true
//            }
        }
        
        
    }
    // MARK: - FUNC
    //
    func toolbar() {
        // 툴바
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = UIColor.white
        self.inputTextView.inputAccessoryView = toolbar
        // 카메라버튼
        let attachImage = UIBarButtonItem()
        attachImage.image = UIImage(named: "camera.png")
        attachImage.tintColor = UIColor.piAquamarine
        attachImage.target = self
        attachImage.action = #selector(attachImageButton)
        // Done 버튼
        let done = UIBarButtonItem()
        done.image = UIImage(named: "keyboardhide.png")
        done.tintColor = UIColor.piGreyish
        done.target = self
        done.action = #selector(keyboardDone)
        // flexSpace
//        let selectfolder = UIBarButtonItem()
//        selectfolder.image = UIImage(named: "PEMO_folderCheck")
//        selectfolder.tintColor = UIColor.piAquamarine
//        selectfolder.target = self
//        selectfolder.action = #selector(selectsss)
        //        let selectImage = UIBarButtonItem()
        //
        //        selectImage.setBackgroundImage(self.selectedImage, for: .normal, barMetrics: .compact)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([attachImage, /*flexSpace,selectfolder ,*/flexSpace, done], animated: true)
    }
    @objc func selectsss(sender: UIBarButtonItem) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NAVIFOLDERs") as? PemoFolderCollectionViewController else { return }
        nextViewController.popOverType = PopOver.writeFolder
        nextViewController.delegate = self
        nextViewController.showPopover(barButtonItem: sender)
    }
    @objc func keyboardDone() {
        self.updateAndAdd()
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
            // 서버전송용
            self.selectedImage = img
            // 이미지 나타냄
            self.toolbar()
            //            self.inputImageView.image = img
        }
        picker.dismiss(animated: true) {
            //            self.view.endEditing(true)
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
    func writeMemoAlamo(title: String, content: String, method: HTTPMethod, writeType: WriteType, category_id: Int = 0)/* -> [MemoData] */{
        print("알라모진입")
        var url = ""
        if writeType == .new {
            url = mainDomain + "memo/"
            print("뉴뉴뉴")
        } else {
            guard let pk = self.memoPkTransfer else { return }
            url = mainDomain + "memo/\(pk)/"
            print("pk입니다",pk)
            print("URL입니다",url)
        }
        var parameters: Parameters = ["title":title, "content":content, "category_id":category_id]
        let tokenValue = TokenAuth()
        let headers = tokenValue.getAuthHeaders()
        
        if let image = self.selectedImage {
            
            //multipartFormData.append(UIImageJPEGRepresentation(image, 0.7)!, withName: "image", fileName: "\(title)"+"photo.jpg", mimeType: "image/jpg")
            let imgData = UIImageJPEGRepresentation(image, 1)
            
            let base64String = imgData?.base64EncodedString(options: .lineLength64Characters)
            //            parameters.updateValue(image, forKey: "image")
            parameters.updateValue(base64String!, forKey: "image")
        } else if ((self.memoTransfer?.image) != nil) {
                print("7777777")
            ///////////////////////////////////////////////////////////////
            // didselect (edit)했을 떄 이미지가 빈것으로 감..
            // 걸러야함..
            ///////////////////////////////////////////////////////////////
//            parameters.updateValue("", forKey: "image")
            print("no image")
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            
            for (key, value) in parameters {
                if key == "title" || key == "content" || key == "category_id" {
                    multipartFormData.append(("\(value)").data(using: .utf8)!, withName: key)
                } else if key == "image" {
                    //                    guard let image = self.selectedImage else { return }
                    ////                    multipartFormData.append(UIImageJPEGRepresentation(image, 0.7)!, withName: "image", fileName: "\(title)"+"photo.jpg", mimeType: "image/jpg")
                    //                    let imgData = UIImageJPEGRepresentation(image, 1)
                    //                    let base64String = imgData?.base64EncodedString()
                    
                    
                    multipartFormData.append(("\(value)").data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: url, method: method, headers: headers)
        { (response) in
            switch response {
            case .success(let upload, _, _):
                print("업로드드드드드", upload)
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        print(".success진입")
                        print(url)
                        print(JSON(value))
                        switch writeType {
                        case .new:
                            print("석세스")
                            guard let addNewmemo = Mapper<MemoData>().mapDictionary(JSONObject: value) else {
                                print("new guard let 걸림")
                                
                                return
                                
                            }
                            guard let tempFolder = self.realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: false) else { return }
                            print("나는 aa입니다:                          "  ,addNewmemo)
                            guard let new = addNewmemo["memo"] else { return }
                            print("나는 aa입니다:                          "  ,new)
                            do {
                                for folder in tempFolder {
                                    if folder.id == new.category_id {
                                        try self.realm.write {
                                            folder.memos.append(new)
                                        }
                                    }
                                }
                            } catch {
                                print("\(error)")
                            }
                        case .edit:
                            do {
                                print("writeType : edit진입")
                                guard let new = Mapper<MemoData>().map(JSONObject: value) else { return }
                                guard let tempFolder = self.realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: false) else { return }
                                print("이것은 edit입니다 :   ", new)
                                for folder in tempFolder {
                                    if folder.id == new.category_id {
                                        if self.memoTransfer?.id == new.id {
                                            try self.realm.write {
                                                self.memoTransfer?.id = new.id
                                                self.memoTransfer?.title = new.title
                                                self.memoTransfer?.content = new.content
                                                self.memoTransfer?.image = new.image
                                                self.memoTransfer?.category_id = new.category_id
                                                self.memoTransfer?.created_date = new.created_date
                                                self.memoTransfer?.modified_date = new.modified_date
                                            }
                                        }
                                    }
                                    
                                }
                            } catch {
                                print("\(error)")
                            }
                            
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                    
                })
                
            case .failure(let encodingError):
                print(encodingError)
                Toast(text: "네트워크에러").show()
                
            }
        }
        
        
    }
    
}
extension PemoNewMemoViewController {
    func uiCustom() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "mainviewcolor")!)
        self.bottomView.backgroundColor = UIColor.white
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.becomeFirstResponder()
        //        self.inputTextView.clipsToBounds = true
        self.inputTextView.layer.cornerRadius = 10
        self.inputTextView.layer.borderColor = UIColor.piGreyish.cgColor
        self.inputTextView.layer.borderWidth = 0.5
        self.inputTextView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.inputTextView.layer.shadowOpacity = 0.3
        let p = CGPoint(x: 0.0, y: 0.0)
        self.inputTextView.setContentOffset(p, animated: true)
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.borderColor = UIColor.piGreyish.cgColor
        self.bottomView.layer.borderWidth = 0.3
        self.bottomView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.bottomView.layer.shadowOpacity = 0.3
        //        self.dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.contentMode = .scaleAspectFit
        dateLabel.textColor = UIColor.white
        foldername.contentMode = .scaleAspectFit
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormat.string(from: Date())
        
        
        let rightBar = UIBarButtonItem(customView: dateLabel)
        self.navigationItem.rightBarButtonItem = rightBar
        
        // navigationbar image
        let viewImage = UIImage(named: "navigationbar")
        //        let width = self.navigationController?.navigationBar.frame.size.width
        //        let height = self.navigationController?.navigationBar.frame.size.height
        //        viewImage?.draw(in: CGRect(x: 0, y: 0, width: width!, height: height!))
        self.navigationController?.navigationBar.setBackgroundImage(viewImage, for: .default)
    }
}
extension PemoNewMemoViewController {
    func stringDate(_ value: String) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: value)!
    }
    
    func DateString(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: value as Date)
    }
}
