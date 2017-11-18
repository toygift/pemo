//
//  PemoSearchTableViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 11. 10..
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
import Kingfisher

class PemoSearchTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    private var realm: Realm!
    private var memos: Results<MemoData>!
    private var folders: Results<Folder>!
    private var token: NotificationToken!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
//        self.folders = realm?.objects(Folder.self).sorted(byKeyPath: "id", ascending: false)
        self.memos = realm.objects(MemoData.self).sorted(byKeyPath: "id", ascending: false)
        
        searchBar.delegate = self
        searchBar.placeholder = "검색"
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.piAquamarine
        //        searchBar.enablesReturnKeyAutomatically = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.memos.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.memos[indexPath.row]
        let cellid = row.image == nil ? "memoCell" : "memoCellImg"
        //        let cellId = section.image == nil ? "memoCellWithImage" : "memoCell" // 서버에서 이미지구현시 앞뒤 바꿀것
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid) as? PemoMainTableViewCell
        //        func stringDate(_ value: String) -> Date {
        //            let dateFormatter = DateFormatter()
        //
        //            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //            return dateFormatter.date(from: value)!
        //        let dateFf = DateFormatter()
        //        dateFf.dateFormat = "yyyy-MM-dd"
        //        dateFf.date(from: row.created_date!)
        //
        cell?.title.text = row.created_date
        cell?.contents.text = row.content
        DispatchQueue.main.async {
            guard let path = row.image else { return }
            //            if let imageURL = URL(string: path) {
            let imageURL = URL(string: path)
            cell?.img.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receive, total) in
                print("\(indexPath.row + 1) : \(receive)/\(total)")
            }, completionHandler: { (image, error, cacheType, imageURL) in
                print("\(indexPath.row + 1) : Finished")
            })
//        DispatchQueue.main.async {
//            guard let path = row.image else { return }
//            if let imageURL = URL(string: path) {
//                let task = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
//                    guard let putImage = data else { return }
//                    DispatchQueue.main.async {
//                        cell?.img.image = UIImage(data: putImage)
//                        if cellid == "memoCellImg" {
//                            cell?.img.clipsToBounds = true
//                            cell?.img.layer.cornerRadius = 10
//                            cell?.img.layer.masksToBounds = true
//
//                        }
//
//                    }
//                })
//                task.resume()
//            }
        }
        // imageData????????????????????????????????????????????????????????????????????????????
        
        return cell!
    }
}
extension PemoSearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        memos = realm.objects(MemoData.self).filter("content contains[c] %@", searchText).sorted(byKeyPath: "id", ascending: false)
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      
        
        self.tableView.reloadData()
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
      self.dismiss(animated: true, completion: nil)
        
        
      
        searchBar.endEditing(true)
    }
}
