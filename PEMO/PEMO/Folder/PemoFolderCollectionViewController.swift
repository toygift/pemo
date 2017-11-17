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
import KUIPopOver


protocol PemoFolderCollectionViewControllerDelegate: class {
    func alamo(with: PemoFolderCollectionViewController, indexPath: IndexPath)
    func dismiss(with: PemoFolderCollectionViewController)
}
enum PopOver {
    case mainFolder
    case writeFolder
}

class PemoFolderCollectionViewController: UICollectionViewController, HalfModalPresentable,UITextFieldDelegate, KUIPopOverUsable, PemoFolderCollectionViewCellDelegate, UIGestureRecognizerDelegate {
    
    // 커스텀 Delegate
    weak var delegate: PemoFolderCollectionViewControllerDelegate?
    //    var memoFolderList: [MemoFolderData] = []
    // KUIPopOver
    var contentSize: CGSize {
        return CGSize(width: self.view.frame.width, height: 215)
    }
    // Realm
    func longPress(touch: PemoFolderCollectionViewCell) {
        print("델리게이트")
    }
    
    @IBAction func deleteFolder(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Delete this folder with all memos?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .default) { (alert) in
           //alamofire
        }
//        let subview = alert.view.subviews.first! as UIView
//        let alertContentView = subview.subviews.first! as UIView
//        alertContentView.backgroundColor = UIColor.piAquamarine
//        alertContentView.layer.cornerRadius = 15
        alert.view.tintColor = UIColor.piAquamarine
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func editFolder(_ sender: UIButton) {

        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "FOLDERMAKE") as! FolderMakeViewController
        // 투명하게
        nextViewController.view.backgroundColor = UIColor.white
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.view.alpha = 0.7
        
        self.present(nextViewController, animated: true, completion: nil)
        

    }
    
    
    private var realm: Realm!
    private var folders: Results<Folder>!
    private var token: NotificationToken!
    
    let plusButton = UIButton(type: .custom)
    var popOverType: PopOver!
    var textFieldText: String!
    var folderMakeTextField: UITextField?
    //******************************************************************************************
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    //******************************************************************************************
    
    //MARK: - LifeCycle
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbar()
        print("콜렉션뷰 뷰 디드 로드")
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        //        self.firstGetFolder(method: .get)
        folders = realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: false)
        //                memos = selectedFolder.memos.sorted(byKeyPath: "id", ascending: false)
        token = folders.observe({ (change) in
            self.collectionView?.reloadData()
        })
        
        //        self.collectionView?.frame.size = CGSize(width: self.view.frame.width, height: 215)
        //        self.collectionView?.frame = CGRect(x: 0, y: 400, width: self.view.frame.width, height: 215)
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
        
        // long press gestureRecognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longpress))
        longPressRecognizer.minimumPressDuration = 0.5
//        longpress.delaysTouchesBegan = true
        longPressRecognizer.delegate = self
        longPressRecognizer.cancelsTouchesInView = true
        
        self.collectionView?.addGestureRecognizer(longPressRecognizer)
        
    }

    
    // long press gestureRecognizer
    @objc func longpress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        let p = gestureRecognizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        let cell = self.collectionView?.cellForItem(at: indexPath!) as! PemoFolderCollectionViewCell
        
        if cell.iconImage.isHidden == true {
            
        }
        if gestureRecognizer.state == .began {
            print("롱프레스 시작")
            //여기서 뭔가 해야 이전에 선택된게...사라질거 같은데
            //생각해보장.......졸림
        } else if gestureRecognizer.state == .ended {
            
            
            if let index = indexPath {
                
                cell.iconImage.isHidden = true
                cell.iconlabel.isHidden = true
                cell.deleteFolder.isHidden = false
                cell.editFolder.isHidden = false
                print(index.row)
                
            } else {
                
            }
            print("롱프레스 끝")
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        self.collectionView?.reloadData()
        
        
    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("시뮬테어스")
//        return true
//    }
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("슈드비긴")
//        return true
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("shouldBeRequiredToFailBy")
//        return true
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
//
//        print("shouldReceive")
//        return true
//    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("shouldReceive")
//        self.collectionView?.reloadData()
        return true
    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
////        print("shouldRequireFailureOf")
//        return true
//    }
    
    
    //        let indexPath = self.collectionView?.indexPathForItem(at: p)
//        if indexPath == nil {
//            // 다른곳 롱프레스시
//            print("어라?? nil인 경우")
//        } else if with.state == .began {
//            // 해당 indexPath 롱 프레스시
//            // 1.alert 창
//            // 2.아이콘 띄우기..위치는 어떻게????
//            print("롱프레스 시작")
    
   
            
//            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "FOLDERMAKE") as! FolderMakeViewController
//            // 투명하게
//            nextViewController.view.backgroundColor = UIColor.white
//            nextViewController.modalPresentationStyle = .fullScreen
//            nextViewController.view.alpha = 0.7
//
//            self.present(nextViewController, animated: true, completion: nil)
            
            //        self.present(nextViewController, animated: true) {
            ////            self.dismissPopover(animated: true)
            //        }
//        }
//
//    }
    override func viewWillDisappear(_ animated: Bool) {
        print("콜렉션뷰 뷰윌디스어피어")
        self.delegate?.dismiss(with: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.folders.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "COLLL", for: indexPath) as? PemoFolderCollectionViewCell
        cell?.iconlabel.text = folders[indexPath.row].title
        cell?.deleteFolder.isHidden = true
        cell?.editFolder.isHidden = true
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀렉트 하면 메모뷰 띄워야함
        // 폴더에 들어있는 메모
        
        if self.popOverType == PopOver.mainFolder {
            print("팝오버 타입 0번     ->  딜리게이트로 넘어가라...")
            self.delegate?.alamo(with: self, indexPath: indexPath)
            
        } else {
            
        }
        
        
        
        
    }
    
}
extension PemoFolderCollectionViewController {
    /*************************************************************************************************/
    /*************************************************************************************************/
    /*************************************없어도 됨                ***********************************/
    /*************************************************************************************************/
    /*************************************************************************************************/
    
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
                //                print("불러오기",memoResponse)
                do {
                    try self.realm.write {
                        
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
        
        plusButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(attatch), for: .touchUpInside)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.titleView = plusButton
        
        // cancel 버튼
//        let cancelButton = UIBarButtonItem()
//        cancelButton.title = "취소"
//        cancelButton.tintColor = UIColor.piAquamarine
//        cancelButton.target = self
//        cancelButton.action = #selector(cancelAction)
//        self.navigationItem.leftBarButtonItem = cancelButton
//    }
//    @objc func attatch() {
//        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "FOLDERMAKE") as! FolderMakeViewController
//        // 투명하게
//        nextViewController.view.backgroundColor = UIColor.white
//        nextViewController.modalPresentationStyle = .fullScreen
//        nextViewController.view.alpha = 0.7
//
//        self.present(nextViewController, animated: true, completion: nil)
//
////        self.present(nextViewController, animated: true) {
//////            self.dismissPopover(animated: true)
////        }
    }
    @objc func attatch() {
        self.navigationItem.titleView = nil
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 22))
        self.folderMakeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 24))
        self.folderMakeTextField?.placeholder = "New Name Folder"
        self.folderMakeTextField?.becomeFirstResponder()
        self.folderMakeTextField?.delegate = self
        self.folderMakeTextField?.tintColor = UIColor.brown
        self.folderMakeTextField?.borderStyle = .roundedRect
        // 확인 버튼
        container.addSubview(self.folderMakeTextField!)
        let leftButtonWidth: CGFloat = 35 // left padding
        let rightButtonWidth: CGFloat = 35 // right padding
        let width = view.frame.width - leftButtonWidth - rightButtonWidth
        let offset = (rightButtonWidth - leftButtonWidth) / 2
        
        NSLayoutConstraint.activate([
            (self.folderMakeTextField?.topAnchor.constraint(equalTo: container.topAnchor))!,
            (self.folderMakeTextField?.bottomAnchor.constraint(equalTo: container.bottomAnchor))!,
            (self.folderMakeTextField?.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: -offset))!,
            (self.folderMakeTextField?.widthAnchor.constraint(equalToConstant: width))!
            ])
        let okButton = UIBarButtonItem()
        okButton.title = "완료"
        okButton.tintColor = UIColor.piAquamarine
        okButton.target = self
        okButton.action = #selector(okAction)
        //        naviView.addSubview(naviTextField)

        self.navigationItem.titleView = container

//        self.navigationItem.rightBarButtonItem = okButton
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.folderMakeTextField?.resignFirstResponder()
        self.navigationItem.titleView = plusButton
        //키보드 완료 버튼 눌렀을 경우
        //알라모파이어 폴더 만들고 Realm에 저장
        //
        return true
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
        self.textFieldText = self.folderMakeTextField?.text
        self.folderMakeTextField?.text = ""
        let parameters: Parameters = ["title": self.textFieldText]
        let call = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        // 데이터 서버로 전송
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):

                //                let json =송JSON(value)
                //                print("알라모성공",json)
                //                print("로그인시 호출되는 알라모파이어 입니다    :    ",json)
                guard let memoResponse = Mapper<Folder>().map(JSONObject: value) else { return }
                //                print("생성하기",memoResponse)
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


