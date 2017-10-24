//
//  PemoMainViewController.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit
import KUIPopOver

class PemoMainViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var topView: UIView!
    @IBOutlet var newMemoButton: UIButton!
    @IBOutlet var bottomView: UIView!
    @IBAction func newMemo(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NEWMEMO") as! PemoNewMemoViewController
        viewController.showPopover(sourceView: sender, sourceRect: sender.bounds)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiCustom()
        self.tableView.delaysContentTouches = false
    }
}

extension PemoMainViewController {
    func uiCustom() {
        self.bottomView.addTopBorderWithColor(color: .lightGray, width: 0.8)
        self.newMemoButton.layer.cornerRadius = 10
    }
    
}

