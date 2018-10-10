//
//  ViewController.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setData()
        self.setUI()
        
    }


}

// MARK: - 设置函数封装
extension ViewController {
    func setData() -> Void {
        // 设置addButton
        self.addButton.frame = CGRect.init(x: 0, y: 0,
                                           width: FrameStandard.genericButtonSideLength,
                                           height: FrameStandard.genericButtonSideLength)
        self.addButton.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2,
                                             y: ToolClass.getScreenHeight() / 5 * 4)
        self.addButton.addTarget(self, action: #selector(self.clickAddButtonEvent), for: .touchUpInside)
        
    }
    
    func setUI() -> Void {
        
    }
}

// MARK: - 点击事件
extension ViewController {
    /// addButton点击事件
    @objc func clickAddButtonEvent() -> Void {
        let recordViewController = UIViewController.initVControllerFromStoryboard("RecordViewController")
        
        let tmpNavigationController = UINavigationController.init(rootViewController: recordViewController)
        
        self.present(tmpNavigationController, animated: true) {
            
        }
        
    }
}
