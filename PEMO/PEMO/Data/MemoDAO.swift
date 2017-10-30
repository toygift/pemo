//
//  MemoDAO.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 30..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MemoDAO {
    // 관리 객체 컨텍스트 반환 멤버변수
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    // 저장된 메모 불러오기
    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memoList = [MemoData]()
        let fetchRequset: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        // 최신순 정렬
        let writeDateDesc = NSSortDescriptor(key: "created_date", ascending: false)
        fetchRequset.sortDescriptors = [writeDateDesc]
        // 검색
        
        if let t = text, t.isEmpty == false {
            fetchRequset.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }
        
        do {
            let resultData = try self.context.fetch(fetchRequset)
            print("  fetch  // 저장된 메모 불러오기")
            
            for result in resultData {
                let data = MemoData()
                data.id = result.id
                data.title = result.title
                data.content = result.content
//                data.category_id = result.category_id
//                data.created_date = result.created_date! as Date
//                data.modified_date = result.modified_date! as Date
                data.objectID = result.objectID
                if let image = result.image as Data? {
                    data.image = UIImage(data: image)
                }
                memoList.append(data)
            }
        } catch let error as NSError {
            print("에러 발생 : %s", error.localizedDescription)
        }
        return memoList
    }
    
    // 메모 저장
    func insert(_ data: MemoData) {
        let saveMemo = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
//        saveMemo.id = data.id!
        saveMemo.title = data.title
        saveMemo.content = data.content
//        saveMemo.category_id = data.category_id!
//        saveMemo.writeDate = data.writeDate
//        saveMemo.modifyDate = data.modifyDate
        if let image = data.image {
            saveMemo.image = UIImagePNGRepresentation(image)!
        }
        
        do {
            try self.context.save()
            let tokenValue = TokenAuth()
            if tokenValue.getAuthHeaders() != nil {
                DispatchQueue.main.async {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    let sync = DataSync()
                    sync.memoUploadData(saveMemo)
                    
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                }
            }
        } catch let error as NSError {
            print("에러 발생 : %s", error.localizedDescription)
        }
    }
    // 메모 삭제
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let deleteMemo = self.context.object(with: objectID)
        self.context.delete(deleteMemo)
        
        do {
            try self.context.save()
            
            return true
        } catch let error as NSError {
            print("에러 발생 : %s", error.localizedDescription)
            return false
        }
    }
}

