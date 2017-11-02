//
//  MemoData.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 25..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class Folder: Object, Mappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var created_date: String?
    @objc dynamic var modified_date: String?
    @objc dynamic var memo_count: Int = 0
    let memos: List<MemoData> = List<MemoData>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        created_date <- map["created_date"]
        modified_date <- map["modified_date"]
        memo_count <- map["memo_count"]
    }
}
class MemoData: Object, Mappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var content: String?
    @objc dynamic var image: Data = Data()
    @objc dynamic var category_id: Int = 0
    @objc dynamic var created_date: String?
    @objc dynamic var modified_date: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
//    override class func primaryKey() -> String? {
//        return "id"
//    }

    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        content <- map["content"]
//        image
        category_id <- map["category_id"]
        created_date <- map["created_date"]//, RCustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        modified_date <- map["modified_date"]//, RCustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }
    
}

