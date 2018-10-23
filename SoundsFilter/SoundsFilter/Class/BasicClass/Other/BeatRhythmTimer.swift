//
//  BeatRhythmTimer.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/13.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import AudioKit
import AudioToolbox

class BeatRhythmTimer: NSObject {
    /// 子线程
    static let beatQueue = DispatchQueue.init(label: "beatQueue",
                                              qos: .userInteractive,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .never,
                                              target: nil)
    
    /// 计时器
    static private var shared: DispatchSourceTimer? = nil
    
    /// 当前时间
    static private var currentTime: Double = 0

    /// 重复次数
    static private var repeatCount: Int = 0
    
    /// 节拍声音播放器
    static private let beatPlayer: AVAudioPlayer = {
        let pathStr = Bundle.main.path(forResource: "beatSound.mp3", ofType: nil)
        let player = try! AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: pathStr!))
        
        player.prepareToPlay()
        player.numberOfLoops = 0
        
        return player
    }()
    

}

// MARK: - 外部接口
extension BeatRhythmTimer {
    /// 初始化节奏计时器并开始计时
    static func initializeBeatRhythmTimer() -> Void {
        
        beatQueue.async {
            let duration = GlobalMusicProperties.getBeatDuration() / 20
            
            let tmpTimer = DispatchSource.makeTimerSource()
            tmpTimer.schedule(deadline: DispatchTime.now(),
                              repeating: duration,
                              leeway: DispatchTimeInterval.seconds(0))
            
            tmpTimer.setEventHandler {
                if self.repeatCount != 0 {
                    self.currentTime += duration
                    
                }
                
                self.repeatCount += 1
                
                if (self.repeatCount - 1) % 20 == 0 {
                    beatPlayer.play()
                }
                
            }
            
            self.shared = tmpTimer
            self.shared!.resume()
        }
    }
    
    /// 获取当前时刻到下一个Beat的时间差
    static func getTimeDifferenceFromNowToNextBeat() -> Double {
        
        let beatDuration = GlobalMusicProperties.getBeatDuration()
        
        return beatDuration - self.currentTime.truncatingRemainder(dividingBy: beatDuration)
    }
    
    /// 销毁计时器
    static func destroyTimer() -> Void {
        self.currentTime = 0
        self.repeatCount = 0
        
        if let beatRhythmTimer = self.shared {
            beatRhythmTimer.cancel()
            
        }
        
        self.shared = nil
        beatPlayer.pause()
        beatPlayer.currentTime = 0
    }
    
}
