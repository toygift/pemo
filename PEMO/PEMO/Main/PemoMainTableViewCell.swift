//
//  PemoMainTableViewCell.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 25..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

class PemoMainTableViewCell: UITableViewCell {

//    var memo: MemoData? {
//        didSet {
//            title.text = memo?.title
//            contents.text = memo?.content
//            if let image = memo?.image {
//                let imageURL = URL(string: path)
//                cell?.img.kf.setImage(with: imageURL, placeholder: nil, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receive, total) in
//                    print("\(indexPath.row + 1) : \(receive)/\(total)")
//                }, completionHandler: { (image, error, cacheType, imageURL) in
//                    print("\(indexPath.row + 1) : Finished")
//                })
//            }
//        }
//    }
    
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
        super.layoutSubviews()
  
        self.cellView.layer.cornerRadius = 10
        self.cellView.layer.masksToBounds = true
        
        self.cellView.layer.shadowColor = UIColor.piGreyish.cgColor
        self.cellView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.cellView.layer.shadowOpacity = 0.4
        
        self.cellView.layer.borderWidth = 0.2
        self.cellView.layer.borderColor = UIColor.piGreyish.cgColor
        
        self.contents.numberOfLines = 4
//        self.contents.sizeToFit()
        self.contents.textColor = UIColor.piBrownishGrey
//        self.contents.adjustsFontForContentSizeCategory = true
        
      
        
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
