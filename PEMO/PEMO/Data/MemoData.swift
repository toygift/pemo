//
//  MemoData.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 25..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import CoreData

class MemoData {
    var id: Int64?
    var title: String?
    var content: String?
    var image: UIImage?
    var category_id: Int64?
    var created_date: Date?
    var modified_date: Date?
    
    var objectID: NSManagedObjectID?
}
