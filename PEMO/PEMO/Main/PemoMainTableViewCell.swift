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
    
    var mainMemo: PEMO.MemoData? { didSet { updateUI()}}
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellView.layer.cornerRadius = 7
        self.cellView.layer.borderWidth = 1
        self.cellView.layer.borderColor = UIColor.lightGray.cgColor
       
    }
    
    func updateUI() {
        self.title.text = mainMemo?.title
        self.contents.text = mainMemo?.content
        
        DispatchQueue.global().async {
            guard let path = self.mainMemo?.image else { return }
            if let imageURL = URL(string: path) {
                let task = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
                    guard let putImage = data else { return }
                    DispatchQueue.main.async {
                        self.img.image = UIImage(data: putImage)
                    }
                })
                task.resume()
            }
        }
    }
    
    
}
