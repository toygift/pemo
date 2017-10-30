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

enum MemoDataType {
    case list
    case search
}
class PemoMainViewController: UIViewController {

    lazy var memoDao = MemoDAO()
    
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//    var memoDataList: [MemoData] = [] // 메모 리스트
    
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

        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NEWMEMO") as? PemoNewMemoViewController else { return }
        nextViewController.writeType = .new
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
        
//        self.getMainMemo()
    }
    
    // MARK: - LIFE CYCLE
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        print("뷰디드로드")
        
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.searchBar.enablesReturnKeyAutomatically = false
//        self.getMainMemo()
        
//        self.tableView.delaysContentTouches = false
//        self.tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.contentInset = UIEdgeInsetsMake(-1, -0, 0, 0)
//        self.tableView.reloadData()
        
        print("전",self.appDelegate.memoDataList)
        memoTypeSelect = .list
//        self.appDelegate.memoDataList = self.memoDao.fetch()
        self.appDelegate.memoDataList = self.memoDao.fetch()
        print("후",self.appDelegate.memoDataList)
        self.tableView.reloadData()
        self.uiCustom()
        self.tableView.backgroundColor = UIColor.piPaleGrey
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("프리페어포세그")
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
        
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }
    override func viewWillAppear(_ animated: Bool) {
        print("뷰윌어피어")
//        self.appDelegate.memoDataList = self.memoDao.fetch()
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("뷰디드어피어")
        self.tableView.reloadData()

    }
    
}
// MARK:- SearchBar Delegate
//
extension PemoMainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        let keyword = searchBar.text
        self.appDelegate.memoDataList = self.memoDao.fetch(keyword: keyword)
        self.tableView.reloadData()
//        if self.searchBar.text == "" {
//            Toast(text: "검색할 단어를 입력하세요").show()
//        } else {
//            guard let search = self.searchBar.text else { return }
//            self.search(search: search)
//            self.searchBar.text = ""
//        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
    }
}
// MARK: - TableView
//
extension PemoMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch self.memoTypeSelect {
//        case .list:
            return self.appDelegate.memoDataList.count
//        case .search:
//            return self.memoSearch.count
//        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch  self.memoTypeSelect {
//        case .list:
            let row = self.appDelegate.memoDataList[indexPath.row]
            //        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as? PemoMainTableViewCell
            cell?.title.text = row.title
            cell?.contents.text = row.content
            print("row",row)
        
            return cell!
//        case .search:
//            let row: MemoData = self.memoSearch[indexPath.row]
//            //        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
//            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as? PemoMainTableViewCell
//            cell?.title.text = row.title
//            cell?.contents.text = row.content
//            return cell!
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didselect")
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "NEWMEMO") as? PemoNewMemoViewController else { return }
        nextViewController.writeType = .edit
//        switch self.memoTypeSelect {
//        case .list:
            nextViewController.memoTransfer = self.appDelegate.memoDataList[indexPath.row]

//        case .search:
//            nextViewController.memoTransfer = self.memoSearch[indexPath.row]
//        }
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            switch self.memoTypeSelect {
//            case .list:
//                ////                self.tableView.beginUpdates()
//                //                self.appDelegate.memoDataList.remove(at: indexPath.row)
//                ////                let indexSet = IndexSet(arrayLiteral: indexPath.section)
//                ////                tableView.deleteSections(indexSet, with: .automatic)
//                //                self.tableView.endUpdates()
                let data = self.appDelegate.memoDataList[indexPath.row]
                if self.memoDao.delete(data.objectID!) {
                    let id = self.appDelegate.memoDataList[indexPath.row]
                    print("아이디지우기기기기긱",id.id!)
                    self.memoDelete(id: id.id!)
                    self.appDelegate.memoDataList.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.reloadData()
//                }
//
//            case .search:
//                self.tableView.beginUpdates()
//                //                guard let id = self.memoSearch[indexPath.row].id else { return }
//                self.memoSearch.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                //                let indexSet = IndexSet(arrayLiteral: indexPath.section)
//                //                tableView.deleteSections(indexSet, with: .fade)
//                //                self.delete(id: id)
//                //                self.tableView.reloadData()
            }
            //            switch self.memoTypeSelect {
            //            case .list:
            //                                self.tableView.beginUpdates()
            //                guard let id = self.memoDataList[indexPath.row].id else { return }
            //                self.memoDataList.remove(at: indexPath.row)
            ////                let indexSet = IndexSet(arrayLiteral: indexPath.section)
            ////                tableView.deleteSections(indexSet, with: .fade)
            //                tableView.deleteRows(at: [indexPath], with: .fade)
            //
            //                self.delete(id: id)
            ////                self.getMainMemo()
            //                self.tableView.endUpdates()
            //                self.tableView.reloadData()
            //
            //            case .search:
            //                self.tableView.beginUpdates()
            //                guard let id = self.memoSearch[indexPath.row].id else { return }
            //                self.memoSearch.remove(at: indexPath.row)
            //                tableView.deleteRows(at: [indexPath], with: .fade)
            ////                                let indexSet = IndexSet(arrayLiteral: indexPath.section)
            ////                                tableView.deleteSections(indexSet, with: .fade)
            //                self.delete(id: id)
            //                self.tableView.reloadData()
            //            }
        }
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 1
//        } else {
//            return cellSpacingHeight
//        }
//
//    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return nil
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return cellSpacingHeight
//    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//
//            switch self.memoTypeSelect {
//            case .list:
//////                self.tableView.beginUpdates()
//                guard let id = self.appDelegate.memoDataList[indexPath.row].id else { return }
////                self.appDelegate.memoDataList.remove(at: indexPath.row)
////                tableView.deleteRows(at: [indexPath], with: .fade)
//////                let indexSet = IndexSet(arrayLiteral: indexPath.section)
//////                tableView.deleteSections(indexSet, with: .automatic)
//                self.memoDelete(id: id)
//                self.tableView.reloadData()
////                self.tableView.endUpdates()
//                let data = self.appDelegate.memoDataList[indexPath.row]
//                if self.memoDao.delete(data.objectID!) {
//                    self.appDelegate.memoDataList.remove(at: indexPath.row)
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
//                }
//
//            case .search:
//                self.tableView.beginUpdates()
////                guard let id = self.memoSearch[indexPath.row].id else { return }
//                self.memoSearch.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
////                let indexSet = IndexSet(arrayLiteral: indexPath.section)
////                tableView.deleteSections(indexSet, with: .fade)
////                self.delete(id: id)
////                self.tableView.reloadData()
//            }
//            // 알라모
////            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//
//        }
//        delete.backgroundColor = UIColor.piViolet
//
//        return [delete]
//    }

//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 5))
//        headerView.backgroundColor = UIColor.black
//        return headerView
//    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.memoDataList[section].title
//    }
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let header = view as? UITableViewHeaderFooterView {
//            header.tintColor = UIColor.piPaleGrey
//        }
//    }
    
   
}

//// MARK: - Alamofire
extension PemoMainViewController {
//    // 메모 불러오기
//    func getMainMemo() {
//        let url = mainDomain + "memo/"
//        let tokenValue = TokenAuth()
//        guard let headers = tokenValue.getAuthHeaders() else { return }
//        let call = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
//        call.responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                print(json)
//                self.navigationItem.title = "ALL"
//                self.navigationItem.rightBarButtonItem = nil
//                self.memoTypeSelect = MemoDataType.list
//                self.appDelegate.memoDataList = DataManager.shared.memoList(response: json)
//                self.tableView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                print("가나다라마마마",self.appDelegate.memoDataList)
//                
//            case .failure(let error):
//                print(error)
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }
//    }
//    // 메모검색
//    func search(search: String) {
//        let url = mainDomain + "memo/?search=\(search)"
//        guard let searchEncoding = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
//        let tokenValue = TokenAuth()
//        guard let headers = tokenValue.getAuthHeaders() else { return }
//        let call = Alamofire.request(searchEncoding, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
//        call.responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                print(json)
//                self.navigationItem.title = "검색결과"
//                self.navigationItem.rightBarButtonItem = self.mainBarButton
//                self.memoTypeSelect = MemoDataType.search
//                self.memoSearch = DataManager.shared.memoList(response: json)
//                self.tableView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                print("가나다", self.memoSearch)
//                
//            case .failure(let error):
//                print(error)
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }
//    }
//    // 메모삭제
    func memoDelete(id: Int64) {
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

