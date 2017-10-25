//
//  PemoMainViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KUIPopOver

class PemoMainViewController: UIViewController, UISearchBarDelegate {

    var memoDataList: [MemoData] = []
    var memoSearch: [MemoData] = []
    // MARK: - @IB
    //
    @IBOutlet var tableView: UITableView!
    @IBOutlet var topView: UIView!
    @IBOutlet var newMemoButton: UIButton!
    @IBOutlet var bottomView: UIView!
    
    
    
    @IBAction func newMemo(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NEWMEMO") as! PemoNewMemoViewController
//        viewController.showPopover(sourceView: sender, sourceRect: sender.bounds)
//        self.navigationController?.pushViewController(viewController, animated: true)
        self.present(viewController, animated: true, completion: nil)
    }
    @IBAction func search(_ sender: UIButton) {
        let searchBar = UISearchBar()
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "검색"
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.enablesReturnKeyAutomatically = false
//        let keyword = searchBar.text
//        self.memoSearch = self.memoDataList
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getMainMemo()
        self.uiCustom()
        self.tableView.delaysContentTouches = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
}

extension PemoMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memoDataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: MemoData = self.memoDataList[indexPath.row]
        let cellId = row.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것 
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PemoMainTableViewCell
        cell?.mainMemo = row
        
        return cell!
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}




extension PemoMainViewController {
    func getMainMemo() {
        let url = mainDomain + "memo/"
        let tokenValue = TokenAuth()
        guard let headers = tokenValue.getAuthHeaders() else { return }
        let call = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.memoDataList = DataManager.shared.memoList(response: json)
                self.tableView.reloadData()
                print(self.memoDataList)
            case .failure(let error):
                print(error)
            }
        }
    }
}


// MARK: - uiCustom
//
extension PemoMainViewController {
    func uiCustom() {
        self.bottomView.addTopBorderWithColor(color: .lightGray, width: 0.8)
        self.newMemoButton.layer.cornerRadius = 7
        self.newMemoButton.layer.borderColor = UIColor.lightGray.cgColor
        self.newMemoButton.layer.borderWidth = 1
        
    }
}

