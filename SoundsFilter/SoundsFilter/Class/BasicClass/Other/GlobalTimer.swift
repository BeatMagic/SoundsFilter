
//
//  GlobalTimer.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/11.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class GlobalTimer: NSObject {
// MARK: - 一般属性
    /// 子线程
    static let globalTimerQueue = DispatchQueue.init(label: "globalTimerQueue",
                                                      qos: .userInteractive,
                                                      attributes: .concurrent,
                                                      autoreleaseFrequency: .never,
                                                      target: nil)
    
    /// 最大时长
    static private let MaxDuration: Double = 27
    
    /// 代理
    weak static var delegate: TimerDelegate?
    
    /// 计时器
    static private var shared: DispatchSourceTimer? = nil
    
// MARK: - 需要重置属性
    /// 当前时间
    static private var currentTime: Double = 0
    
    /// 重复次数
    static private var repeatCount: Int = 0

}

// MARK: - 外部接口
extension GlobalTimer {
    /// 初始化计时器并开始计时
    static func initializeTimer() -> Void {
        globalTimerQueue.async {
            // 重置当前时间
            self.currentTime = 0
            self.repeatCount = 0
            let timeInterval = GlobalMusicProperties.getDetectFrequencyDuration()
            
            let tmpTimer = DispatchSource.makeTimerSource()
            tmpTimer.schedule(deadline: DispatchTime.now(),
                              repeating: timeInterval,
                              leeway: DispatchTimeInterval.seconds(0))
            
            tmpTimer.setEventHandler {
                // 第一次不触发要做的事
                if self.repeatCount != 0 {
                    self.currentTime += timeInterval
                    self.delegate?.doThingsWhenTiming()
                    
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

    
    /// 获取当前时间
    static func getCurrentTime() -> Double {
        
        return self.currentTime
    }
    
    /// 获取当前重复次数
    static func getRepeatCount() -> Int {
        
        return self.repeatCount
    }
    
    /// 销毁计时器 destroy
    static func destroyTimer() -> Void {
        self.delegate?.doThingsWhenEnd()
        
        if let timer = self.shared {
            timer.cancel()
            
        }
        
        self.shared = nil
        
    }
}

protocol TimerDelegate: class {
    /// 间隔任务
    func doThingsWhenTiming()
    
    /// 结束时任务
    func doThingsWhenEnd()
}
