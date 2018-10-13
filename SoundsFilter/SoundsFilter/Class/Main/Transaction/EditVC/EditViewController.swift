//
//  EditViewController.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
// MARK: - 状态属性
    /// 是否在记录中
    private var recordStatus: StaticProperties.EditVCStatus = .Initial
    
// MARK: - UI
    /// 进度条
    private var playProgressBar: PlayProgressBar? {
        didSet {
            self.view.addSubview(playProgressBar!)
        }
    }
    
    
    /// 播放按钮
    private lazy var playButton: UIButton = {
        let tmpButton = UIButton.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: FrameStandard.genericButtonSideLength / 3 * 2,
                height: FrameStandard.genericButtonSideLength / 3 * 2
            )
        )
        
        tmpButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
        tmpButton.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2,
                                        y: ToolClass.getScreenHeight() / 5 * 4)
        tmpButton.addTarget(self, action: #selector(self.clickRecordButtonEvent), for: .touchUpInside)
        
        self.view.addSubview(tmpButton)
        
        return tmpButton
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playProgressBar = PlayProgressBar.init(totalTimeLength: AudioKitLogger.getAudioFileTotalTime())
        
        AudioKitLogger.setPlayerCompletionHandler {
            self.recordStatus = .Initial
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
            AudioKitLogger.stopPlayingFile()
            self.playProgressBar!.cursorCancelAnimation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setData()
        self.setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.playProgressBar = nil
        AudioKitLogger.setPlayerCompletionHandler {
            
        }
    }

}

// MARK: - 设置函数封装
extension EditViewController {
    func setData() -> Void {
        
    }
    
    func setUI() -> Void {
        self.navigationItem.leftBarButtonItem = self.backButtonItem
        self.playButton.tag = 1
        
        
    }
}

// MARK: - 点击事件
extension EditViewController {
    /// 点击返回
    @objc func clickBackButtonEvent() -> Void {
        self.dismiss(animated: true) {
            
        }
        
    }// funcEnd
    
    /// 点击播放/停止
    @objc func clickRecordButtonEvent() -> Void {
        switch self.recordStatus {
        case .Initial:
            self.recordStatus = .Playing
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.stopPlaying.rawValue), for: .normal)
            AudioKitLogger.playFile()
            self.playProgressBar!.cursorAnimation()
            
        case .Playing:
            self.recordStatus = .Initial
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
            AudioKitLogger.stopPlayingFile()
            self.playProgressBar!.cursorCancelAnimation()
        }
        
        
        
    }// funcEnd
}
