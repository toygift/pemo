//
//  DataManager.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 25..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import Foundation
import SwiftyJSON


let mainDomain: String = "https://pemo.co.kr/api/"
let serviceName: String = "co.kr.pemo.PEMO"



class DataManager {
    static let shared: DataManager = DataManager()
    
    // MARK: User
    ///
    //
    func userList(response json: JSON) -> User {
        let user = User(id: json["id"].intValue,
                        username: json["username"].stringValue,
                        user_type: json["user_type"].stringValue)
        return user
    }
    func memoList(response json: JSON) -> [MemoData] {
        let memo: [MemoData] = json.arrayValue.map { (json) -> MemoData in
            let value = MemoData(id: json["id"].intValue,
                                 title: json["title"].stringValue,
                                 content: json["content"].stringValue,
                                 image: json["image"].stringValue,
                                 category_id: json["category_id"].intValue)
                                 
            return value
        }
        return memo
    }
    func folderList(response json: JSON) -> [MemoFolderData] {
        let memo: [MemoFolderData] = json.arrayValue.map { (json) -> MemoFolderData in
            let value = MemoFolderData(id: json["id"].intValue,
                                       title: json["title"].stringValue)
            
            return value
        }
        return memo
    }
}
