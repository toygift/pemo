//
//  DataSync.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 30..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class DataSync {
    // 코어데이터 컨텍스트
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func memoDownload() {
        let userD = UserDefaults.standard
        guard userD.value(forKey: "firstLogin") == nil else { return }
        let tokenValue = TokenAuth()
        guard let header = tokenValue.getAuthHeaders() else { return }
        let url = mainDomain + "memo/"
        let call = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("다운로드앗따", json)
                for jsonValue in json.arrayValue {
                    let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                    object.id = jsonValue["id"].int64Value
                    object.title = jsonValue["title"].stringValue
                    object.content = jsonValue["content"].stringValue
                    object.category_id = jsonValue["category_id"].int64Value
                    object.created_date = self.stringDate(jsonValue["created_date"].stringValue)
                    object.modified_date = self.stringDate(jsonValue["modified_date"].stringValue)
                    object.sync = true
                    //                    let imagePath = jsonValue["image"].stringValue
                    //                    let url = URL(string: imagePath)!
                    //                    object.image = try! Data(contentsOf: url)
                }
                
                
                do {
                    try self.context.save()
                    
                } catch let error as NSError {
                    print("에러발생 %s", error.localizedDescription)
                }
            //                ud.setValue
            case .failure(let error):
                print(error)
            }
            userD.setValue(true, forKey: "firstLogin")
        }
        
    }
    
    func memoUpload() {
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        //        let writeDateDesc = NSSortDescriptor(key: "created_date", ascending: false)
        //        fetchRequest.sortDescriptors = [writeDateDesc]
        fetchRequest.predicate = NSPredicate(format : "sync == false")
        
        do {
            let resultData = try self.context.fetch(fetchRequest)
            print("DataSync.swift // func memoUpload", resultData)
            for result in resultData {
                //                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.memoUploadData(result) {
                    //                    if result === resultData.last {
                    //                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    func memoUploadData(_ item: MemoMO, complete: (() -> Void)? = nil) {
        print("메모 업로드 데이터")
        let tokenValue = TokenAuth()
        guard let headers = tokenValue.getAuthHeaders() else { return }
        let url = mainDomain + "memo/"
        guard let title = item.title, let content = item.content else {
            print ("가드레레레레레레레레렛")
            return
            
        }
        let parameters: Parameters = ["title": title, "content": content]
        print("가",item.title!)
        print("나",item.content!)
        print("다",item.category_id)
        let call = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        call.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let jsonValue = JSON(value)
                print("dididididi",jsonValue)
                let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                object.id = jsonValue["memo"]["id"].int64Value
                object.title = jsonValue["memo"]["title"].stringValue
                object.content = jsonValue["memo"]["content"].stringValue
                object.category_id = jsonValue["memo"]["category_id"].int64Value
                object.created_date = self.stringDate(jsonValue["memo"]["created_date"].stringValue)
                object.modified_date = self.stringDate(jsonValue["memo"]["modified_date"].stringValue)
                
                object.sync = true
                
                do {
                    item.sync = true
                    try self.context.save()
                } catch let error as NSError {
                    self.context.rollback()
                    print("에러발생 %s", error.localizedDescription)
                }
                complete?()
            case .failure(let error):
                print(error)
            }
        }
    }
    func memoDelete(id: Int64) {
        // 메모삭제
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

extension DataSync {
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
