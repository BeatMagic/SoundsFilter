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
    
    /// 是否可以更改BPM
    var canChangeBPM: Bool = false

    
    // MARK: - UI
    /// 调整BPM按钮
    private lazy var changeBPMButton: SizeSlideButton = {
        let sideLength = FrameStandard.genericButtonSideLength / 2
        
        let tmpButton = SizeSlideButton.init(condensedFrame:
            CGRect.init(x: (ToolClass.getScreenWidth() - sideLength ) / 2,
                        y: ToolClass.getScreenHeight() / 5 * 4 - sideLength * 3,
                        width: sideLength,
                        height: sideLength)
        )
        
        let wholeWidth = ToolClass.getScreenWidth() / 2 - sideLength

        tmpButton.frame = CGRect.init(
            x: ToolClass.getScreenWidth() / 2 - wholeWidth + sideLength / 2,
            y: ToolClass.getScreenHeight() / 5 * 4 - sideLength * 3,
            width: wholeWidth,
            height: sideLength
        )
        
        tmpButton.trackColor = UIColor.flatGray
        tmpButton.handle.color = UIColor.flatRed
        
        tmpButton.addTarget(self, action: #selector(self.touchDownChangeBPMButtonEvent), for: .touchDown)
        tmpButton.addTarget(self, action: #selector(self.valueChangedChangeBPMButtonEvent), for: .valueChanged)
        tmpButton.addTarget(self, action: #selector(self.touchDragFinishedChangeBPMButtonEvent), for: .touchDragFinished)
        
        self.view.addSubview(tmpButton)
        
        return tmpButton
    }()

    /// BPM数值Label
    private lazy var bPMCountLabel: UILabel = {
        let width = FrameStandard.genericButtonSideLength
        let height = width / 4
        
        let tmpLabel = UILabel.init(frame: CGRect.init(x: 0,
                                                       y: 0,
                                                       width: width,
                                                       height: height))
        tmpLabel.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2 + width,
                                       y: ToolClass.getScreenHeight() / 5 * 4 - width / 2 * 3 + height)
        
        tmpLabel.font = UIFont.systemFont(ofSize: 11)
        tmpLabel.text = "BPM:\(GlobalMusicProperties.musicBPM)"
        tmpLabel.textColor = UIColor.flatGrayDark
        
        self.view.addSubview(tmpLabel)
        
        return tmpLabel
    }()
    
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
        self.changeBPMButton.tag = 2
        self.recordButton.tag = 1
        self.recordTitleLabel.text = "录制"
        self.bPMCountLabel.tag = 1
        
        AudioKitLogger.initializeLogger()
    }
    
    func setUI() -> Void {
        self.navigationItem.leftBarButtonItem = self.backButtonItem
        
    }
}

// MARK: - 点击事件
extension RecordViewController {
    // MARK: 导航栏
    /// 点击返回
    @objc func clickBackButtonEvent() -> Void {
        self.dismiss(animated: true) {
        }
        
    }// funcEnd
    
    // MARK: BPM按钮
    /// 长按BPM按钮
    @objc func touchDownChangeBPMButtonEvent() -> Void {
        if self.recordStatus != .Recording {
            self.canChangeBPM = true
            
        }
    }
    
    /// 滑动BPM按钮
    @objc func valueChangedChangeBPMButtonEvent(_ sender: SizeSlideButton) -> Void {
        if self.canChangeBPM == true {
            let value = sender.value
            let roundingBPM = lroundf(value * 80 + 60)
            GlobalMusicProperties.musicBPM = Double(roundingBPM)
            
            self.bPMCountLabel.text = "BPM:\(GlobalMusicProperties.musicBPM)"
        }
    }
    
    /// 结束点击BPM按钮
    @objc func touchDragFinishedChangeBPMButtonEvent() -> Void {
        self.canChangeBPM = false
    }
    
    // MARK: 录制按钮
    /// 点击记录/停止
    @objc func clickRecordButtonEvent() -> Void {
        switch self.recordStatus {
        case .Initial:
            self.recordStatus = .Recording
            #warning("开始录制")
            self.recordButton.setImage(UIImage.init(named: StaticProperties.ImageName.stopped.rawValue), for: .normal)
            self.recordTitleLabel.text = "停止"
            
            // 创建计时器并开始计时
            GlobalTimer.delegate = self
            GlobalTimer.initializeTimer(timeInterval: 0.1)
            
            // 开始录制
            AudioKitLogger.startRecording()
            
            
            
        case .Recording:
            self.recordStatus = .Initial
            self.recordButton.setImage(UIImage.init(named: StaticProperties.ImageName.record.rawValue), for: .normal)
            self.recordTitleLabel.text = "录制"
            
            // 销毁计时器与AudioKit
            GlobalTimer.destroyTimer()
            AudioKitLogger.stopRecording()
            
            // 页面跳转
            let editViewController = UIViewController.initVControllerFromStoryboard("EditViewController")
            self.navigationController!.pushViewController(editViewController, animated: true)
            
        }
        
        
        
    }// funcEnd
}

extension RecordViewController: TimerDelegate {
    func doThingsWhenTiming() {
        GlobalMusicProperties.recordFrequencyArray.append(AudioKitLogger.getRealtimeNote())
        
    }
    
    func doThingsWhenEnd() {
        print("已经结束")
        
        if self.recordStatus == .Recording {
            self.clickRecordButtonEvent()
            
        }

    }
}
