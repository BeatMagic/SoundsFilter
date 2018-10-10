//
//  RecordViewController.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    /// 返回ButtonItem
    lazy var backButtonItem: UIBarButtonItem = {
        let tmpButton = UIButton.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: 25,
                height: 25
            )
        )
        
        tmpButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        tmpButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        tmpButton.setImage(
            UIImage.init(named: ImageNameStandard.ImageName.back.rawValue),
            for: .normal
        )
        
        tmpButton.addTarget(self, action: #selector(self.clickBackButtonEvent), for: .touchUpInside)
        
        return UIBarButtonItem.init(customView: tmpButton)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setData()
        self.setUI()
    }
}

// MARK: - 设置函数封装
extension RecordViewController {
    func setData() -> Void {
        self.navigationItem.leftBarButtonItem = self.backButtonItem
        
    }
    
    func setUI() -> Void {
        
    }
}

// MARK: - 点击事件
extension RecordViewController {
    /// 点击返回
    @objc func clickBackButtonEvent() -> Void {
        self.dismiss(animated: true) {
        }
        
    }// funcEnd
}
