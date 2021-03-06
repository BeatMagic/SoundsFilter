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
    private var bracketsViewArray: [UILabel]! {
        didSet {
            for bracketsView in bracketsViewArray {
                self.addSubview(bracketsView)
                
            }
        }
    }
    
    private var isNeedEdit = true
    
    // MARK: - 记录
    /// 记录括号位置数组
    private var bracketsLoction: [Double] = [0, GlobalMusicProperties.timeDifferenceFromNowToNextBeat] {
        didSet {
            if oldValue != bracketsLoction {
                GlobalMusicProperties.bracketsSelectedTime = bracketsLoction[0] ... bracketsLoction[1]
                
                if let action = didSetBracketsLoctionAction {
                    
                    action()
                    
                }
                
            }
            
            
        }
    }
    
    /// 设置括号位置数组后做的事
    var didSetBracketsLoctionAction: (() -> Void?)? = nil

    /// 记录线横坐标的的数组
    private var sectionLineXArray: [CGFloat] = []
    
    
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
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
        
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
        
        self.sectionLineXArray.append(0)
        
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
            self.sectionLineXArray.append(currentSectionLineX)
            
            currentSectionLineX += CGFloat(beatDuration) * FrameStandard.OneSecondProgressWidth * 4
        }
        
        self.sectionLineXArray.append(CGFloat(self.totalTime) * FrameStandard.OneSecondProgressWidth)
        
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
        var tmpLabelArray: [UILabel] = []
        
        var currentX: CGFloat = 0
        for index in 0 ..< 2 {
            let bracketsLabel = UILabel.init(frame:CGRect.init(
                x: currentX, y: FrameStandard.genericButtonSideLength / 2,
                width: FrameStandard.cursorSideLength, height: FrameStandard.cursorSideLength * 2
            ))
            bracketsLabel.font = UIFont.systemFont(ofSize: 15)
            
            switch index {
            case 0:
                bracketsLabel.text = "{"
                
            case 1:
                bracketsLabel.text = "}"
                
                
            default:
                print("不应该来的地方")
            }
            
            tmpLabelArray.append(bracketsLabel)
            currentX += FrameStandard.cursorSideLength / 2
            
        }
        
        self.bracketsViewArray = tmpLabelArray
    }
}

extension PlayProgressBar {
    // MARK: - 运动相关
    /// 游标开始运动
    func cursorAnimation() -> Void {
        UIView.animate(
            withDuration: self.totalTime,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.cursorView.frame.origin.x = CGFloat(self.totalTime) * FrameStandard.OneSecondProgressWidth
            },
            completion: { (isFinished) in
                if isFinished == true {
                    self.cursorView.frame.origin.x = 0
                }
            }
            
        )
    }
    
    /// 取消游标运动
    func cursorCancelAnimation() -> Void {
        self.cursorView.isHidden = true
        self.cursorView.layer.removeAllAnimations()
        
        self.cursorView.frame.origin.x = 0
        self.cursorView.isHidden = false
    }
    
    /// 获取左右括号位置
    func getBracketsLoction() -> [Double] {
        return self.bracketsLoction
    }
    
    /// 是否解锁括号
    func lockOrUnlock(_ isUnlocking: Bool) -> Void {
        self.isUserInteractionEnabled = isUnlocking
    }
    
    // MARK: - 工具
    /// 运动
    private func getNearestBrackets(point: CGPoint) -> Void {
        var lineDistanceArray: [Float] = []
        for sectionLineX in self.sectionLineXArray {
            let distance = fabsf(Float(point.x - sectionLineX))
            lineDistanceArray.append(distance)
            
        }
        
        var nearestLineIndex = 0
        var nearestLineDistance: Float = 1000
        
        for index in 0 ..< lineDistanceArray.count {
            let distance = lineDistanceArray[index]
            
            if distance <= nearestLineDistance {
                nearestLineIndex = index
                nearestLineDistance = distance
            }
            
        }
        
        
        
        var distanceArray: [Float] = [0, 0]
        
        for index in 0 ..< 2 {
            let brackets = self.bracketsViewArray[index]
            let distance = fabsf(Float(self.sectionLineXArray[nearestLineIndex] - brackets.getX()))
            
            distanceArray[index] = distance
            
        }
        
        var needMoveBracketsIndex = 0
        if distanceArray[0] > distanceArray[1] {
            needMoveBracketsIndex = 1
            
        }
        
        
        UIView.animate(
            withDuration: 0.001,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.bracketsViewArray[needMoveBracketsIndex].frame.origin.x = self.sectionLineXArray[nearestLineIndex]
            },
            
            completion: { (isFinished) in
                var result = 0.0
                
                if nearestLineIndex >= 1 && nearestLineIndex <= self.sectionLineXArray.count - 2 {
                    result = Double(nearestLineIndex - 1) * GlobalMusicProperties.getSectionDuration() + GlobalMusicProperties.timeDifferenceFromNowToNextBeat
                    
                }else if nearestLineIndex == self.sectionLineXArray.count - 1 {
                    result = self.totalTime
                    
                }
                

                self.bracketsLoction[needMoveBracketsIndex] = result
                
            }
        )
        

    }

    
}

// MARK: - 重载Touch事件
extension PlayProgressBar {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            self.getNearestBrackets(point: touch.location(in: self))
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            self.getNearestBrackets(point: touch.location(in: self))
//        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            self.getNearestBrackets(point: touch.location(in: self))
        }
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.getNearestBrackets(point: touch.location(in: self))
        }
    }
}


