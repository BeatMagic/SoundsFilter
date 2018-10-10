//
//  RecordViewController.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecordViewController: UIViewController {
// MARK: - 状态属性
    /// 是否在记录中
    var recordStatus: StaticProperties.RecordVCStatus = .Initial
    
// MARK: - UI
    /// 录制按钮
    private lazy var recordButton: UIButton = {
        let tmpButton = UIButton.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: FrameStandard.genericButtonSideLength,
                height: FrameStandard.genericButtonSideLength
            )
        )
        tmpButton.setImage(UIImage.init(named: StaticProperties.ImageName.record.rawValue), for: .normal)
        tmpButton.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2,
                                        y: ToolClass.getScreenHeight() / 5 * 4)
        tmpButton.addTarget(self, action: #selector(self.clickRecordButtonEvent), for: .touchUpInside)
        
        self.view.addSubview(tmpButton)
        
        return tmpButton
    }()
    
    /// 录制状态标题
    private lazy var recordTitleLabel: UILabel = {
        let tmpLabel = UILabel.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: FrameStandard.genericButtonSideLength,
                height: FrameStandard.genericButtonSideLength / 2
            )
        )
        tmpLabel.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2,
                                        y: ToolClass.getScreenHeight() / 5 * 4 + FrameStandard.genericButtonSideLength / 3 * 2)
        tmpLabel.font = UIFont.systemFont(ofSize: 17)
        tmpLabel.textColor = UIColor.flatBlack
        tmpLabel.textAlignment = .center
        
        self.view.addSubview(tmpLabel)
        return tmpLabel
    }()

    /// 返回ButtonItem
    private lazy var backButtonItem: UIBarButtonItem = {
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
            UIImage.init(named: StaticProperties.ImageName.back.rawValue),
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
        self.recordButton.tag = 1
        self.recordTitleLabel.text = "录制"
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
    
    /// 点击记录/停止
    @objc func clickRecordButtonEvent() -> Void {
        switch self.recordStatus {
        case .Initial:
            self.recordStatus = .Recording
            #warning("开始录制")
            self.recordButton.setImage(UIImage.init(named: StaticProperties.ImageName.stopped.rawValue), for: .normal)
            self.recordTitleLabel.text = "停止"
            
        case .Recording:
            self.recordStatus = .Initial
            self.recordButton.setImage(UIImage.init(named: StaticProperties.ImageName.record.rawValue), for: .normal)
            self.recordTitleLabel.text = "录制"
            
            // 页面跳转
            let editViewController = UIViewController.initVControllerFromStoryboard("EditViewController")
            self.navigationController!.pushViewController(editViewController, animated: true)
            
        }
        
        
        
    }// funcEnd
}
