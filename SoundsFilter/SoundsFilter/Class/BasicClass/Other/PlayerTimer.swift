//
//  PlayerTimer.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/18.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class PlayerTimer: NSObject {
    /// 子线程
    static let playerTimerQueue = DispatchQueue.init(label: "playerTimerQueue",
                                                     qos: .userInteractive,
                                                     attributes: .concurrent,
                                                     autoreleaseFrequency: .never,
                                                     target: nil)
    
    /// 最大时长
    static private let MaxDuration: Double = AudioKitLogger.getAudioFileTotalTime()!
    
    /// 计时器
    static private var shared: DispatchSourceTimer? = nil
    
    // MARK: - 需要重置属性
    /// 当前时间
    static private var currentTime: Double = 0
    
    /// 重复次数
    static private var repeatCount: Int = 0
    
    static private var timelineArray: [(Double, Double)] = []
    static private var adjustIndexArray: [Double] = []
    
    static private var isAllowShift: Bool = true
    
}

// MARK: - 外部接口
extension PlayerTimer {
    /// 初始化计时器并开始计时
    static func initializeTimer() -> Void {

        playerTimerQueue.async {
            // 重置当前时间
            self.currentTime = 0
            self.repeatCount = 0
            self.timelineArray = GlobalMusicProperties.timelineArray
            self.adjustIndexArray = GlobalMusicProperties.adjustIndexArray

            let timeInterval = GlobalMusicProperties.getDetectFrequencyDuration() / 20
            
            let tmpTimer = DispatchSource.makeTimerSource()
            tmpTimer.schedule(deadline: DispatchTime.now(),
                              repeating: timeInterval,
                              leeway: DispatchTimeInterval.seconds(0))
        
            
            tmpTimer.setEventHandler {
                
                
                // 第一次不触发要做的事
                if self.repeatCount != 0 {
                    
                    let delay = GlobalMusicProperties.getSectionDuration() - GlobalMusicProperties.timeDifferenceFromNowToNextBeat
                    
                    if let bracketsSelectedTime = GlobalMusicProperties.bracketsSelectedTime {
                        
                        if bracketsSelectedTime.contains(self.currentTime - delay) == true {
                            AudioKitLogger.samplerMixer!.volume = 1.0
                            
                        }else {
                            AudioKitLogger.samplerMixer!.volume = 0
                            
                        }
                    }
                    
                    self.currentTime += timeInterval
                    
                    if self.isNeedTuning() != nil && isAllowShift == true { // 需要调音
                        
                        isAllowShift = false
                        AudioKitLogger.setPitchShifter(shift: self.adjustIndexArray[self.isNeedTuning()!])
                        
                    }else if self.isNeedTuning() == nil  { // 不需要调
                        
                        isAllowShift = true
                        AudioKitLogger.setPitchShifter(shift: 0)
                        
                    }else { // 在区间内但不调音
                        
                        
                    }


                }
                
                self.repeatCount += 1
                
                if self.currentTime >= MaxDuration {
                    self.destroyTimer()
                    
                }
            }
            
            self.shared = tmpTimer
            self.shared!.resume()
            
            
        }
        

    }
    
    /// 销毁计时器 destroy
    static func destroyTimer() -> Void {
        
        if let timer = self.shared {
            timer.cancel()
            
        }
        

        
        self.shared = nil
        
    }
    
    /// 判断是否需要调音
    static func isNeedTuning() -> Int? {
        
        if let bracketsSelectedTime = GlobalMusicProperties.bracketsSelectedTime {
            
            let delay = GlobalMusicProperties.getSectionDuration() - GlobalMusicProperties.timeDifferenceFromNowToNextBeat
            
            for index in 0 ..< self.timelineArray.count {
                
                if self.currentTime >= self.timelineArray[index].0
                    &&
                    self.currentTime <= self.timelineArray[index].1
                    &&
                    bracketsSelectedTime.contains(self.currentTime - delay) == true {
                    
                    return index
                }
                
            }
            
        }
        
        return nil

    }// funcEnd
}
