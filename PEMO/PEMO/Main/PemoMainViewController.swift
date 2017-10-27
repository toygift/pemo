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
import Toaster

enum MemoDataType: Int {
    case list = 0
    case search = 1
}
class PemoMainViewController: UIViewController {

    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    var memoDataList: [MemoData] = [] // 메모 리스트
    var memoSearch: [MemoData] = [] // 메모검색결과 리스트
    let cellSpacingHeight: CGFloat = 10
    let searchBar = UISearchBar()
    var memoTypeSelect: MemoDataType = .list
    // MARK: - @IB
    //
    @IBOutlet var tableView: UITableView!
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var newMemoButton: UIButton!
    @IBOutlet var mainBarButton: UIBarButtonItem!
    @IBAction func folder(_ sender: UIButton) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NAVIFOLDER") else { return }
        self.present(nextViewController, animated: true, completion: nil)
    }
    @IBAction func newMemo(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "NAVINEWMEMO") //as! PemoNewMemoViewController
////        viewController.showPopover(sourceView: sender, sourceRect: sender.bounds)
////        self.navigationController?.pushViewController(viewController, animated: true)
//        self.present(viewController, animated: true, completion: nil)
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NEWMEMO") as? PemoNewMemoViewController else { return }
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "검색"
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
//        searchBar.enablesReturnKeyAutomatically = false

    }
    @IBAction func goToMain(_ sender: UIBarButtonItem) {
        
        self.getMainMemo()
    }
    
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.getMainMemo()
        self.uiCustom()
        self.tableView.delaysContentTouches = false
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = UIColor.piPaleGrey
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
        
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }
    override func viewWillAppear(_ animated: Bool) {
        
//        self.getMainMemo()
//        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.getMainMemo()
        self.tableView.reloadData()
    }
}
// MARK:- SearchBar Delegate
//
extension PemoMainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        if self.searchBar.text == "" {
            Toast(text: "검색할 단어를 입력하세요").show()
        } else {
            guard let search = self.searchBar.text else { return }
            self.search(search: search)
            self.searchBar.text = ""
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
    }
}
// MARK: - TableView
//
extension PemoMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.memoTypeSelect {
        case .list:
            return self.memoDataList.count
        case .search:
            return self.memoSearch.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch  self.memoTypeSelect {
        case .list:
            let section: MemoData = self.memoDataList[indexPath.section]
            //        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as? PemoMainTableViewCell
            cell?.mainMemo = section
            return cell!
        case .search:
            let section: MemoData = self.memoSearch[indexPath.section]
            //        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as? PemoMainTableViewCell
            cell?.mainMemo = section
            return cell!
        }
        
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            switch self.memoTypeSelect {
            case .list:
                guard let id = self.memoDataList[indexPath.section].id else { return }
                self.memoDataList.remove(at: indexPath.section)
                //            tableView.deleteRows(at: [indexPath], with: .fade)
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                tableView.deleteSections(indexSet, with: .fade)
                self.delete(id: id)
            case .search:
                guard let id = self.memoSearch[indexPath.section].id else { return }
                self.memoSearch.remove(at: indexPath.section)
                //            tableView.deleteRows(at: [indexPath], with: .fade)
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                tableView.deleteSections(indexSet, with: .fade)
                self.delete(id: id)
            }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didselect")
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NEWMEMO") as? PemoNewMemoViewController else { return }
        switch self.memoTypeSelect {
        case .list:
            nextViewController.navigationItemTitle = self.memoDataList[indexPath.section].title
            nextViewController.textViewContents = self.memoDataList[indexPath.section].content
        case .search:
            nextViewController.navigationItemTitle = self.memoSearch[indexPath.section].title
            nextViewController.textViewContents = self.memoSearch[indexPath.section].content
        }
        self.navigationController?.pushViewController(nextViewController, animated: true)
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
                self.navigationItem.title = "ALL"
                self.navigationItem.rightBarButtonItem = nil
                self.memoTypeSelect = MemoDataType.list
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
    // 메모검색
    func search(search: String) {
        let url = mainDomain + "memo/?search=\(search)"
        guard let searchEncoding = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        let tokenValue = TokenAuth()
        guard let headers = tokenValue.getAuthHeaders() else { return }
        let call = Alamofire.request(searchEncoding, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.navigationItem.title = "검색결과"
                self.navigationItem.rightBarButtonItem = self.mainBarButton
                self.memoTypeSelect = MemoDataType.search
                self.memoSearch = DataManager.shared.memoList(response: json)
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("가나다", self.memoSearch)
                
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

