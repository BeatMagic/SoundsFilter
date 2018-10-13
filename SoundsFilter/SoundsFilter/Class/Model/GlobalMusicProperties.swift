//
//  GlobalMusicProperties.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/11.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

// MARK: - BPM相关
class GlobalMusicProperties: NSObject {
    /// 速度
    static var musicBPM: Double = 120 {
        didSet {
            if musicBPM > 140 {
                musicBPM = 140
                
            }else if musicBPM < 60 {
                musicBPM = 60
                
            }else {
                self.resetDataAboutMusicBPM()
                
            }
        }
    }
    
    /// 小节时长
    static private var sectionDuration: Double = 240 / musicBPM
    
    /// beat时长
    static private var beatDuration: Double = sectionDuration / 4
    
    // MARK: -
    /// 获取当前小节时长
    static func getSectionDuration() -> Double {
        return self.sectionDuration
    }
    
    /// 获取当前beat时长
    static func getBeatDuration() -> Double {
        return self.beatDuration
    }
    
    /// 更改速度后重设相关数据
    static private func resetDataAboutMusicBPM() -> Void {
        self.sectionDuration = 240 / self.musicBPM
        self.beatDuration = self.sectionDuration / 4
        
        BeatRhythmTimer.destroyTimer()
        BeatRhythmTimer.initializeBeatRhythmTimer()
        
    }// funcEnd
    
}

// MARK: - 记录数据
extension GlobalMusicProperties {
    /// 声音频率记录数组
    static var recordFrequencyArray: [Float?] = []
    
    /// 当前时刻到下一个Beat的时间差
    static var timeDifferenceFromNowToNextBeat: Double = 0.0
}

// MARK: - 静态数据
extension GlobalMusicProperties {
    /// 声音频率表(对应)
    static let NoteFrequencies: [Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]

    /// 音阶
    static let NoteNamesWithSharps: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    

    
}


