//
//  PemoMainTableViewCell.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 25..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

class PemoMainTableViewCell: UITableViewCell {

    
    @IBOutlet var cellView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var contents: UILabel!
    @IBOutlet var img: UIImageView!
    @IBOutlet var regDate: UILabel!
    @IBOutlet var modifyDate: UILabel!
    
    var mainMemo: PEMO.MemoData? { didSet { updateUI()}}
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.uiCustom()
       
    }
    override func layoutSubviews() {
        self.cellView.layer.cornerRadius = 7
        self.cellView.layer.masksToBounds = false
        
        self.cellView.layer.shadowColor = UIColor.piGreyish.cgColor
        self.cellView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.cellView.layer.shadowOpacity = 0.4
        
        self.cellView.layer.borderWidth = 0.2
        self.cellView.layer.borderColor = UIColor.piGreyish.cgColor
        self.title.textColor = UIColor.piBrownishGrey
        self.contents.textColor = UIColor.piBrownishGrey
    }
}

extension PemoMainTableViewCell {
    // 테이블뷰 uiCustom
    func uiCustom() {
        
    }
    // 테이블뷰 셀에 내용 표시
    func updateUI() {
        self.title.text = mainMemo?.title
        self.contents.text = mainMemo?.content
        // 이미지
//        DispatchQueue.global().async {
//            guard let path = self.mainMemo?.image else { return }
//            if let imageURL = URL(string: path) {
//                let task = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
//                    guard let putImage = data else { return }
//                    DispatchQueue.main.async {
//                        self.img.image = UIImage(data: putImage)
//                    }
//                })
//                task.resume()
//            }
//        }
    }
}
