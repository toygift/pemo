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


class PemoMainViewController: UIViewController, UISearchBarDelegate {

    var memoDataList: [MemoData] = []
    var memoSearch: [MemoData] = []
    let cellSpacingHeight: CGFloat = 10
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
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.enablesReturnKeyAutomatically = false
//        let keyword = searchBar.text
//        self.memoSearch = self.memoDataList
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getMainMemo()
        self.uiCustom()
        self.tableView.delaysContentTouches = false
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = UIColor.piPaleGrey
    }
}

extension PemoMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.memoDataList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: MemoData = self.memoDataList[indexPath.section]
//        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as? PemoMainTableViewCell
        cell?.mainMemo = section
//        cell?.title.text = self.memoDataList[indexPath.section].title
//        cell?.title.text = self.memoDataList[indexPath.row].title
        return cell!
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            guard let id = self.memoDataList[indexPath.section].id else { return }
            self.memoDataList.remove(at: indexPath.section)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            tableView.deleteSections(indexSet, with: .fade)
            self.delete(id: id)
            // 알라모
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
        }
        delete.backgroundColor = UIColor.piViolet
        
        return [delete]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        headerView.backgroundColor = UIColor.piPaleGrey
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}



// MARK: - Alamofire
extension PemoMainViewController {
    // 메모 불러오기
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("가나다라마마마",self.memoDataList)
                
            case .failure(let error):
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    // 메모삭제
    func delete(id: Int) {
        let url = mainDomain + "memo/\(id)/"
        let tokenValue = TokenAuth()
        guard let headers = tokenValue.getAuthHeaders() else { return }
        let call = Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .failure(let error):
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

