//
//  AudioKitLogger.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/11.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class AudioKitLogger: NSObject {
    /// 麦克风
    static private var mic = AKMicrophone()
    
    /// 跟踪器
    static private var tracker = AKFrequencyTracker(mic)
    
    static private var silence = AKBooster(tracker, gain: 0)
}

// MARK: - 外部接口
extension AudioKitLogger {
    /// 初始化
    static func initializeLogger() -> Void {
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
    }

    /// 销毁
    static func destroyLogger() -> Void {
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        
    }
    
    /// 获取实时音符字符串
    static func getRealtimeNote() -> Float? {
        // 当音量大于0.5时
        if self.tracker.amplitude >= 0.5 {
            
            return Float(tracker.frequency)
        }
        
        return nil
    }
    
}

extension AudioKitLogger {
    
    
    
}
