//
//  PemoFolderCollectionViewCell.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 27..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit

protocol PemoFolderCollectionViewCellDelegate: class {
    func longPress(touch: PemoFolderCollectionViewCell)
}


class PemoFolderCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PemoFolderCollectionViewCellDelegate?
    
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var iconlabel: UILabel!
    @IBOutlet weak var deleteFolder: UIButton!
    @IBOutlet weak var editFolder: UIButton!
    @IBAction func deleteAction(_ sender: UIButton) {
        print("Delete")
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        print("Edit")
    }
    override func layoutSubviews() {
        self.deleteFolder.isHidden = true
        self.editFolder.isHidden = true
    }
    
    
    //롱 프레스시에 레이블 버튼 사라지게
    //롱프레스시에 원래 아이콘이미지 사라지게
    
//    끝난후에 다시 나타나게
//    델리게이트 써야됨?
    
    
    //    override func layoutSubviews() {
//        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longpress))
//        longpress.minimumPressDuration = 1.0
//        self.iconImage.gestureRecognizers = [longpress]
//    }
//    
//    
//    @objc func longpress(with: UILongPressGestureRecognizer) {
//        //        if with.state == .began {
//        //            let long = with.location(in: self.newMemoButton)
//        //
//        //            let press = self.newMemoButton.convert(long, to: self.newMemoButton)
//        print("메롱메롱")
//    }
}
