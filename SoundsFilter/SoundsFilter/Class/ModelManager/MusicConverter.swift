//
//  MusicConverter.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/12.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

// MARK: - 频率相关
class MusicConverter: NSObject {
    /// 给定一个频率 量化到一个音名
    /*
     static func getMusicalAlphabetFrom(frequency: Double) -> String {
     let noteFrequencies = GlobalMusicProperties.NoteFrequencies
     var tmpFrequency = frequency
     
     
     // 确定到音
     while frequency > noteFrequencies[noteFrequencies.count - 1] {
     tmpFrequency /= 2.0
     }
     
     while frequency < noteFrequencies[0] {
     tmpFrequency *= 2.0
     }
     
     var minDistance: Float = 10_000.0
     var index = 0
     
     for i in 0 ..< noteFrequencies.count {
     let distance = fabsf(noteFrequencies[i] - frequency)
     if distance < minDistance {
     index = i
     minDistance = distance
     }
     }
     
     // 获取八度
     let octave = Int(log2f(Float(frequency / tmpFrequency)))
     
     return "\(GlobalMusicProperties.NoteNamesWithSharps[index])\(octave)"
     
     
     }// funcEnd
     */
    
    
    /// 通过一个音高字符串("C4")获取该音高的频率
    static func getFrequencyFrom(pitchName: String) -> Double {
        let pitchScale = self.getFrequencyArrayIndexFrom(pitchName: pitchName)
        
        let octaveCountString = ToolClass.cutStringWithPlaces(
            pitchName, startPlace: pitchName.count - 1, endPlace: pitchName.count
        )
        
        let needExponentialCoefficient = pow(2, Double(octaveCountString)!)
        
        return GlobalMusicProperties.NoteFrequencies[pitchScale] * needExponentialCoefficient
        
    }
    
    /// 通过一个音高字符串("C4")获取该音高的频率的数组index
    static func getFrequencyArrayIndexFrom(pitchName: String) -> Int {
        var pitchScale = 0
        
        for index in 0 ..< GlobalMusicProperties.NoteNamesWithSharps.count {
            let scale = GlobalMusicProperties.NoteNamesWithSharps[index]
            
            if (pitchName.range(of: scale) != nil) {
                pitchScale = index
            }
        }
        
        return pitchScale
    }
    
    /// 给定一个频率 求其近似pitch
    static func getApproximatePitch(frequency: Double) -> String {
        var index = 0

        for model in GlobalMusicProperties.PitchFrequencyModelArray {
            if model.fequency < frequency {
                index += 1
                
            }else {
                break
                
            }
        }
        
        let prevModel = GlobalMusicProperties.PitchFrequencyModelArray[index - 1]
        let nextModel = GlobalMusicProperties.PitchFrequencyModelArray[index]
        
        
        if (frequency - prevModel.fequency) <= (nextModel.fequency - frequency) {
            return prevModel.pitchName
            
        }else {
            
            return nextModel.pitchName
        }

    }// funcEnd
    
    /// 给定一个频率 求其纵坐标高
    static func getFrameY(frequency: Double) -> Double {
        var index = 0
        
        for model in GlobalMusicProperties.PitchFrequencyModelArray {
            if model.fequency < frequency {
                index += 1
                
            }else {
                break
                
            }
        }
        
        let prevModel = GlobalMusicProperties.PitchFrequencyModelArray[index - 1]
        let nextModel = GlobalMusicProperties.PitchFrequencyModelArray[index]
        
        // 第几个八度
        let scale = ToolClass.cutStringWithPlaces(prevModel.pitchName, startPlace: prevModel.pitchName.count - 1, endPlace: prevModel.pitchName.count)
        
        // 音名
        let musicalAlphabet = ToolClass.cutStringWithPlaces(prevModel.pitchName, startPlace: 0, endPlace: prevModel.pitchName.count - 1)
        
        var noteNamesIndex: Double = 0
        for noteNames in GlobalMusicProperties.NoteNamesWithSharps {
            if musicalAlphabet == noteNames {
                break
            }
            
            noteNamesIndex += 1
            
        }
        
        let scaleLength = Double(GlobalMusicProperties.NoteNamesWithSharps.count * Int(scale)!) + noteNamesIndex
        
        
        
        return scaleLength + (frequency - prevModel.fequency) / (nextModel.fequency - prevModel.fequency)
        
    }// funcEnd
    
    
    
    /// 频率数组提纯
    static func purifyFrequencyModel(frequencyArray: [Double?]) -> [FrequencyDurationModel] {
        var frequencyModelArray: [FrequencyDurationModel] = []
        
        var currentTime = 0.0
        for frequency in frequencyArray {
            if let existFrequency = frequency {
                
                let model = FrequencyDurationModel.init(frequency: existFrequency, startTime: currentTime)
                
                frequencyModelArray.append(model)
                
            }
            
            currentTime += GlobalMusicProperties.getDetectFrequencyDuration()
        }
        
        return frequencyModelArray
        
    }// funcEnd
    
    
    
    
}

// MARK: - 音符相关
extension MusicConverter {
    /// 给定一个音阶与八度信息 返回音高midi音符数字
    static func getMidiNote(_ scaleName: String, octaveCount: Int, isRising: Bool?) -> UInt8 {
        var tmpScale: UInt8 = 0
        let tmpOctaveCount = UInt8(octaveCount)
        
        
        switch scaleName {
        case "A":
            tmpScale = 9
            
        case "B":
            tmpScale = 11
            
        case "C":
            tmpScale = 0
            
        case "D":
            tmpScale = 2
            
        case "E":
            tmpScale = 4
            
        case "F":
            tmpScale = 5
            
        case "G":
            tmpScale = 7
            
        default:
            return 0
        }
        
        if isRising != true {
            return tmpScale + tmpOctaveCount * 12 + 24
            
        }else {
            return tmpScale + tmpOctaveCount * 12 + 1 + 24
            
        }
        
    }// funcEnd
    
    /// 通过一个音符字符串("C4")获取音高
    static func getMidiNoteFromString(_ noteString: String) -> UInt8 {
        let scale = ToolClass.cutStringWithPlaces(
            noteString, startPlace: 0, endPlace: 1
        )
        
        let octaveCountString = ToolClass.cutStringWithPlaces(
            noteString, startPlace: noteString.count - 1, endPlace: noteString.count
        )
        
        let isRising: Bool = {
            if noteString.range(of: "#") == nil {
                return false
                
            }
            
            return true
            
        }()
        
        return self.getMidiNote(scale, octaveCount: Int(octaveCountString)!, isRising: isRising)
        
    }
    
    
    
}

// MARK: - 文件相关
extension MusicConverter {
    /// 通过一个音色文件名获取midi音符数字
    static func getMidiNoteFromFileName(_ toneFileName: String) -> UInt8 {
        
        let toneFileNoSuffixName = ToolClass.cutStringWithPlaces(toneFileName, startPlace: 0, endPlace: toneFileName.count - 4)
        
        
        if let range = toneFileName.range(of: "_") {
            // 获取音符字符串
            let noteString = ToolClass.cutStringWithPlaces(toneFileNoSuffixName, startPlace: range.upperBound.encodedOffset, endPlace: toneFileNoSuffixName.count)
            
            return self.getMidiNoteFromString(noteString) - 12
        }
        
        return 0
        
    }// funcEnd
}
