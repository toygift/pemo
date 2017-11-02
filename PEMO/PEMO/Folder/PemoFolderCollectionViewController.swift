//
//  PemoFolderCollectionViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 27..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

private let reuseIdentifier = "cell"

class PemoFolderCollectionViewController: UICollectionViewController, HalfModalPresentable, UITextFieldDelegate {
    
    //    var memoFolderList: [MemoFolderData] = []
    
    
    private var realm: Realm!
    private var folders: Results<Folder>!
    private var token: NotificationToken!
    var textFieldText: String!
    var naviTextField: UITextField?
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolbar()
        print("콜렉션뷰 뷰 디드 로드")
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        self.firstGetFolder(method: .get)
        folders = realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: false)
        //        memos = selectedFolder.memos.sorted(byKeyPath: "id", ascending: false)
        token = folders.observe({ (change) in
            self.collectionView?.reloadData()
        })
        
        //        navigationItem.title = selectedFolder.title
        
        //        let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 230, height: 24))
        //        textfield.placeholder = "폴더이름"
        ////        textfield.layer.cornerRadius = 1
        ////        textfield.layer.borderColor = UIColor.piViolet.cgColor
        ////        textfield.layer.borderWidth = 0.8
        //        textfield.setBottomBorder()
        //        textfield.backgroundColor = UIColor.piPaleGrey
        //        textfield.delegate = self
        //        self.navigationItem.titleView = textfield
        //        self.navigationItem.titleView?.backgroundColor = UIColor.piPaleGrey
        //        self.navigationController?.navigationBar.backgroundColor = UIColor.piPaleGrey
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.folders.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "COLLL", for: indexPath) as? PemoFolderCollectionViewCell
        cell?.iconlabel.text = folders[indexPath.row].title
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀렉트 하면 메모뷰 띄워야함
        // 폴더에 들어있는 메모
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MAIN") as? PemoMainViewController else { return }
        nextViewController.folderId = folders[indexPath.row].id
        nextViewController.transCollection = false
        
        self.present(nextViewController, animated: true, completion: nil)
    }
}
extension PemoFolderCollectionViewController {
    func firstGetFolder(method: HTTPMethod) {
        print("알라모")
        //        let userDefault = UserDefaults.standard
        //        guard userDefault.value(forKey: "firstloginFolder") == nil else { return }
        
        let url = mainDomain + "category/"
        let tokenValue = TokenAuth()
        let headers = tokenValue.getAuthHeaders()
        let call = Alamofire.request(url, method: method, parameters: nil, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                print("알라모성공",json)
                //                print("로그인시 호출되는 알라모파이어 입니다    :    ",json)
                guard let memoResponse = Mapper<Folder>().mapArray(JSONObject: value) else { return }
                print("불러오기",memoResponse)
                do {
                    try self.realm.write {
                        for i in memoResponse {
                            self.realm.add(i)
                            print(i)
                        }
                    }
                } catch {
                    
                }
                //                userDefault.setValue(true, forKey: "firstloginFolder")
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}
extension PemoFolderCollectionViewController {
    func toolbar() {
        // 툴바
        //        let toolbar = UIToolbar()
        //        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        //        toolbar.backgroundColor = UIColor.white
        //        self.inputTextView.inputAccessoryView = toolbar
        
        // plus버튼
        let plusImage = UIImage(named: "plus")
        let plusButton = UIButton(type: .custom)
        plusButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(attatch), for: .touchUpInside)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.titleView = plusButton
        // cancel 버튼
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "취소"
        cancelButton.tintColor = UIColor.piAquamarine
        cancelButton.target = self
        cancelButton.action = #selector(cancelAction)
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func attatch() {
        self.navigationItem.titleView = nil
        self.naviTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 230, height: 24))
        self.naviTextField?.placeholder = "폴더명을 입력하세요"
        self.naviTextField?.becomeFirstResponder()
        self.naviTextField?.delegate = self
        // 확인 버튼
        let okButton = UIBarButtonItem()
        okButton.title = "완료"
        okButton.tintColor = UIColor.piAquamarine
        okButton.target = self
        okButton.action = #selector(okAction)
        //        naviView.addSubview(naviTextField)
        
        self.navigationItem.titleView = naviTextField
        
        self.navigationItem.rightBarButtonItem = okButton
    }
    @objc func cancelAction() {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    @objc func okAction() {
        // 빈텍스트일경우 경고창
        
        let url = mainDomain + "category/"
        let tokenValue = TokenAuth()
        let headers = tokenValue.getAuthHeaders()
        self.textFieldText = self.naviTextField?.text
        self.naviTextField?.text = ""
        let parameters: Parameters = ["title": self.textFieldText]
        let call = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                print("알라모성공",json)
                //                print("로그인시 호출되는 알라모파이어 입니다    :    ",json)
                guard let memoResponse = Mapper<Folder>().map(JSONObject: value) else { return }
                print("생성하기",memoResponse)
                do {
                    try self.realm.write {
                        self.realm.add(memoResponse)
                    }
//                    if let delegate = self.navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
//                        delegate.interactiveDismiss = false
//                    }
//
//                    self.dismiss(animated: true, completion: nil)
                } catch {
                    print("\(error)")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


