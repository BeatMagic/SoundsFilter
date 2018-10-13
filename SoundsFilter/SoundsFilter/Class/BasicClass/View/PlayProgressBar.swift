//
//  PlayProgressBar.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/13.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class PlayProgressBar: UIView {
    // MARK: - UI元素
    /// 进度条
    private var progressView: UIView! {
        didSet {
            self.addSubview(progressView)
            
        }
    }

    /// 游标
    private var cursorView: UIImageView! {
        didSet {
            self.addSubview(cursorView)
            
        }
    }
    
    /// 左右括号数组
    private var bracketsViewArray: [UIView]! {
        didSet {
            for bracketsView in bracketsViewArray {
                self.addSubview(bracketsView)
                
            }
        }
    }
    
    // MARK: - 记录
    private let totalTime: Double!
    
    // MARK: - 各种初始化方法
    init(totalTimeLength: Double) {
        self.totalTime = totalTimeLength
        
        let frame = CGRect.init(
            x: 0,
            y: 0,
            width: CGFloat(self.totalTime) * FrameStandard.OneSecondProgressWidth + FrameStandard.cursorSideLength,
            height: FrameStandard.genericButtonSideLength
        )
        
        // 初始化整体View
        super.init(frame: frame)
        self.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2, y: FrameStandard.genericButtonSideLength * 4)
        
        self.initializeProgressView(totalTimeLength: self.totalTime)
        self.initializeCursorView()
        self.initializeBracketsViewArray()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化进度条
    private func initializeProgressView(totalTimeLength: Double) -> Void {
        let backgourdView = UIView.init(frame:
            CGRect.init(x: FrameStandard.cursorSideLength / 2,
                        y: 0,
                        width: CGFloat(self.totalTime) * FrameStandard.OneSecondProgressWidth,
                        height: FrameStandard.genericButtonSideLength / 2
            )
        )
        backgourdView.backgroundColor = UIColor.flatWhite
        
        
        let beatDuration = GlobalMusicProperties.getBeatDuration()
        let endingExtraTime = (self.totalTime - GlobalMusicProperties.timeDifferenceFromNowToNextBeat).truncatingRemainder(dividingBy: beatDuration)
        
        let needBeatLineTime = self.totalTime - GlobalMusicProperties.timeDifferenceFromNowToNextBeat - endingExtraTime
        
        let beatLineCount = Int.init(needBeatLineTime / beatDuration)
        
        // 目前BeatLine的X
        var currentSectionLineX = CGFloat(GlobalMusicProperties.timeDifferenceFromNowToNextBeat) * FrameStandard.OneSecondProgressWidth
        
        let sectionLineCount = (beatLineCount - beatLineCount % 4) / 4 + 1
        
        for _ in 0 ..< sectionLineCount {
            let beatLine = UIView.init(frame: CGRect.init(
                x: currentSectionLineX,
                y: (FrameStandard.genericButtonSideLength / 2  - FrameStandard.genericButtonSideLength / 2 / 3 * 2) / 2,
                width: 1.5,
                height: FrameStandard.genericButtonSideLength / 2 / 3 * 2
            ))
            
            beatLine.backgroundColor = UIColor.flatYellow
            backgourdView.addSubview(beatLine)
            
            currentSectionLineX += CGFloat(beatDuration) * FrameStandard.OneSecondProgressWidth * 4
        }
        
        self.progressView = backgourdView
        
    }
    
    /// 初始化游标
    private func initializeCursorView() -> Void {
        let cursorView = UIImageView.init(image: UIImage.init(named: StaticProperties.ImageName.cursor.rawValue))
        cursorView.frame = CGRect.init(
            x: 0,
            y: -FrameStandard.cursorSideLength / 2,
            width: FrameStandard.cursorSideLength,
            height: FrameStandard.cursorSideLength
        )
        
        self.cursorView = cursorView
    }
    
    /// 初始化{}
    private func initializeBracketsViewArray() -> Void {
        
    }
}

extension PlayProgressBar {
    // MARK: - 运动相关
    /// 游标开始运动
    func cursorAnimation() -> Void {
        UIView.animate(withDuration: self.totalTime,
                       delay: 0,
                       options: [],
                       animations: {
                        self.cursorView.frame.origin.x = CGFloat(self.totalTime) * FrameStandard.OneSecondProgressWidth
        },
                       completion: { (isFinished) in
                        if isFinished == true {
                            self.cursorView.frame.origin.x = 0
                        }
        })
    }
    
    /// 取消游标运动
    func cursorCancelAnimation() -> Void {
        self.cursorView.isHidden = true
        self.cursorView.layer.removeAllAnimations()
        
        self.cursorView.frame.origin.x = 0
        self.cursorView.isHidden = false
    }

    
}
