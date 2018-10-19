//
//  AboutPitchFrequency.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/15.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class AboutPitchFrequency: NSObject {

    
}

class PitchFrequencyModel: NSObject {
    /// 音阶名
    let pitchName: String!
    
    /// 对应的频率
    let fequency: Double!
    
    init(pitchName: String!) {
        self.pitchName = pitchName
        self.fequency = MusicConverter.getFrequencyFrom(pitchName: self.pitchName)
        
        super.init()
    }
    
}

class FrequencyDurationModel: NSObject {
    /// 频率
    let frequency: Double!
    
    /// 开始时间
    let startTime: Double!
    
    /// 持续时间
    let duration: Double = GlobalMusicProperties.getDetectFrequencyDuration()
    
    /// 结束时间
    let endTime: Double!
    
    init(frequency: Double, startTime: Double) {
        self.frequency = frequency
        self.startTime = startTime
        self.endTime = self.startTime + self.duration
        
        super.init()
    }
}
