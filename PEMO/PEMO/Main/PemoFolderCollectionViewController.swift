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

private let reuseIdentifier = "cell"

class PemoFolderCollectionViewController: UICollectionViewController, HalfModalPresentable, UITextFieldDelegate {

    var memoFolderList: [MemoFolderData] = []
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
        self.getFolder()
        let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 230, height: 24))
        textfield.placeholder = "폴더이름"
//        textfield.layer.cornerRadius = 1
//        textfield.layer.borderColor = UIColor.piViolet.cgColor
//        textfield.layer.borderWidth = 0.8
        textfield.setBottomBorder()
        textfield.backgroundColor = UIColor.piPaleGrey
        textfield.delegate = self
        self.navigationItem.titleView = textfield
        self.navigationItem.titleView?.backgroundColor = UIColor.piPaleGrey
        self.navigationController?.navigationBar.backgroundColor = UIColor.piPaleGrey
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.memoFolderList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "COLLL", for: indexPath) as? PemoFolderCollectionViewCell
        cell?.iconlabel.text = self.memoFolderList[indexPath.row].title
        
        
    
        return cell!
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
extension PemoFolderCollectionViewController {
    func getFolder() {
        let url = mainDomain + "category/"
        let tokenValue = TokenAuth()
        guard let headers = tokenValue.getAuthHeaders() else { return }
        let call = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.memoFolderList = DataManager.shared.folderList(response: json)
                print("메모폴더리스트",self.memoFolderList)
                self.collectionView?.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}
