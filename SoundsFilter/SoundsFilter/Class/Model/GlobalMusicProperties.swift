//
//  GlobalMusicProperties.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/11.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

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
    
    /// 获取当前小节时长
    static func getSectionDuration() -> Double {
        return self.sectionDuration
    }
    
    /// 获取当前beat时长
    static func getBeatDuration() -> Double {
        return self.beatDuration
    }
}

extension GlobalMusicProperties {
    /// 更改速度后重设相关数据
    static private func resetDataAboutMusicBPM() -> Void {
        self.sectionDuration = 240 / self.musicBPM
        self.beatDuration = self.sectionDuration / 4
        
    }// funcEnd
}
