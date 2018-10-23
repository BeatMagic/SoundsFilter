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
                self.sectionDuration = 240 / self.musicBPM
                self.beatDuration = self.sectionDuration / 4
                self.minNoteDuration = 7.5 /  self.musicBPM
                
                self.resetDataAboutMusicBPM()
            }
        }
    }
    
    /// 小节时长
    static private var sectionDuration: Double = 240 / musicBPM
    
    /// beat时长
    static private var beatDuration: Double = sectionDuration / 4
    
    /// 检测频率时长
    static private let detectFrequencyDuration: Double = 0.003
    
    /// 最短音符时长
    static private var minNoteDuration: Double = 7.5 / musicBPM
    
    // MARK: -
    /// 获取当前小节时长
    static func getSectionDuration() -> Double {
        return self.sectionDuration
    }
    
    /// 获取当前beat时长
    static func getBeatDuration() -> Double {
        return self.beatDuration
    }
    
    /// 获取当前检测频率时长
    static func getDetectFrequencyDuration() -> Double {
        return self.detectFrequencyDuration
    }
    
    /// 获取最短音符时长
    static func getMinNoteDuration() -> Double {
        return self.minNoteDuration
    }
    
    /// 更改速度后重设相关数据
    static private func resetDataAboutMusicBPM() -> Void {
        let queueGroup = DispatchGroup.init()
        let basicQueue = DispatchQueue(label: "basicQueue")
        
        
        basicQueue.async(group: queueGroup, execute: {
            BeatRhythmTimer.destroyTimer()
        })
        
        queueGroup.notify(queue: DispatchQueue.main) {
            BeatRhythmTimer.initializeBeatRhythmTimer()
        }
        
        
        
        
    }// funcEnd
    
}

// MARK: - 记录数据
extension GlobalMusicProperties {
    /// 声音频率记录数组
    static var recordFrequencyArray: [Double?] = []
    
    /// 频率提纯Model数组
    static var frequencyModelArray: [[FrequencyDurationModel]] = []
    
    /// 当前时刻到下一个Beat的时间差
    static var timeDifferenceFromNowToNextBeat: Double = 0.0
    
    /// 需要调整的数组
    static var adjustIndexArray: [Double] = []
    
    /// 时间线数组
    static var timelineArray: [(Double, Double)] = []
    
    /// 括号选定前后时间
    static var bracketsSelectedTime: ClosedRange<Double> = 0 ... 1
}

// MARK: - 静态数据
extension GlobalMusicProperties {
    /// 声音频率表(对应)
    static let NoteFrequencies: [Double] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]

    /// 音阶表
    static let NoteNamesWithSharps: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    /// 人声音阶区间
    static private let VocalScaleInterval: [String] = ["E2", "D#6"]
    
    /// 人声频率区间
    static let VocalFrequencyInterval: [Double] = [PitchFrequencyModelArray.first!.fequency, PitchFrequencyModelArray.last!.fequency]
    
    /// 音阶频率表
    static let PitchFrequencyModelArray: [PitchFrequencyModel] = {
        // 最低八度
        let lowestOctaveCount = Int(ToolClass.cutStringWithPlaces(
            VocalScaleInterval.first!, startPlace: VocalScaleInterval.first!.count - 1, endPlace: VocalScaleInterval.first!.count)
        )
        // 最高八度
        let highestOctaveCount = Int(ToolClass.cutStringWithPlaces(
            VocalScaleInterval.last!, startPlace: VocalScaleInterval.last!.count - 1, endPlace: VocalScaleInterval.last!.count)
        )
        
        // 第一个八度的起始
        let lowestOctaveStartIndex = MusicConverter.getFrequencyArrayIndexFrom(pitchName: VocalScaleInterval.first!)
        // 最后一个八度的起始
        let highstOctaveEndIndex = MusicConverter.getFrequencyArrayIndexFrom(pitchName: VocalScaleInterval.last!)
        
        var tmpScaleFrequencyArray: [PitchFrequencyModel] = []
        
        
        for index in lowestOctaveCount! ..< highestOctaveCount! + 1 {
            switch index {
            case lowestOctaveCount:     // 第一个八度
                for frequencyArrayIndex in lowestOctaveStartIndex ..< NoteFrequencies.count {
                    let pitchName = "\(NoteNamesWithSharps[frequencyArrayIndex])\(index)"
                    let model = PitchFrequencyModel.init(pitchName: pitchName)
                    tmpScaleFrequencyArray.append(model)
                    
                }

            case highestOctaveCount:    // 最后一个八度
                for frequencyArrayIndex in 0 ..< highstOctaveEndIndex + 1 {
                    let pitchName = "\(NoteNamesWithSharps[frequencyArrayIndex])\(index)"
                    let model = PitchFrequencyModel.init(pitchName: pitchName)
                    tmpScaleFrequencyArray.append(model)
                    
                }
                
            default:
                for frequencyArrayIndex in 0 ..< NoteFrequencies.count {
                    let pitchName = "\(NoteNamesWithSharps[frequencyArrayIndex])\(index)"
                    let model = PitchFrequencyModel.init(pitchName: pitchName)
                    tmpScaleFrequencyArray.append(model)
                    
                }
            }
            
            
            
        }
        
        
        return tmpScaleFrequencyArray
        
        
        
    }()
    
    
    static var xxxx: [Double] = []
    
}

// MARK: - 大调相关
extension GlobalMusicProperties {
    /// 十二大调音名序列
    static let MajorPitchDict: [String: [String]] = [
        "C": ["C", "D", "E", "F", "G", "A", "B"],
        "C#": ["C#", "D#", "F", "F#", "G#", "A#", "C"],
        "D": ["D", "E", "F#", "G", "A", "B", "C#"],
        "D#": ["D#", "F", "G", "G#", "A#", "C", "D"],
        "E": ["E", "F#", "G#", "A", "B", "C#", "D#"],
        "F": ["F", "G", "A", "A#", "C", "D", "E"],
        "F#": ["F#", "G#", "A#", "B", "C#", "D#", "F"],
        "G": ["G", "A", "B", "C", "D", "E", "F#"],
        "G#": ["G#", "A#", "C", "C#", "D#", "F", "G"],
        "A": ["A", "B", "C#", "D", "E", "F#", "G#"],
        "A#": ["A#", "C", "D", "D#", "F", "G", "A"],
        "B": ["B", "C#", "D#", "E", "F#", "G#", "A#"]
    ]
    
    /// 给定一个NoteModelArray 返回近似大调
    static func getApproximateMajor(noteModelArray: [NoteModel]) -> String {
        var similarityArray: [Double] = []
        
        for majorName in NoteNamesWithSharps {
            let pitchArray = MajorPitchDict[majorName]!
            
            var similarity = 0.0
            
            for noteModel in noteModelArray {
                
                let pitch = ToolClass.cutStringWithPlaces(noteModel.pitchName, startPlace: 0, endPlace: noteModel.pitchName.count - 1)
                
                if pitchArray.contains(pitch) == true {
                    
                    similarity += noteModel.duration
                }
                
            }
            
            similarityArray.append(similarity)
        }
        
        var maxIndex = 0
        var maxCount = 0.0
        
        for index in 0 ..< similarityArray.count {
            let similarity = similarityArray[index]
            
            if maxCount < similarity {
                maxCount = similarity
                maxIndex = index
            }
            
        }
        
        
        return NoteNamesWithSharps[maxIndex]
    }// funcEnd
    
    
    /// 给定大调与任意音名 获取与大调内最近音名
    static func getNearestMajorPitch(majorName: String, pitchName: String) -> String {
        
        let majorPitchArray = MajorPitchDict[majorName]!
        
        let scale = ToolClass.cutStringWithPlaces(pitchName, startPlace: 0, endPlace: pitchName.count - 1)
        let octaveCount = Int(ToolClass.cutStringWithPlaces(pitchName, startPlace: pitchName.count - 1, endPlace: pitchName.count))!
        
        
        if majorPitchArray.contains(scale) {
            return pitchName
            
        }else {
            var majorFrequencyArray: [Double] = []
            
            for majorPitch in majorPitchArray {
                let baseFrequency = MusicConverter.getFrequencyFrom(pitchName: "\(majorPitch)0")
                majorFrequencyArray.append(baseFrequency)
            }
            
            majorFrequencyArray.append(majorFrequencyArray.first! * 2)
            
            let scaleFrequency = MusicConverter.getFrequencyFrom(pitchName: "\(scale)0")
            
            var nearestFrequencyDifference = 1000.0
            var nearestIndex = 0
            
            for index in 0 ..< majorFrequencyArray.count {
                let majorFrequency = majorFrequencyArray[index]
                
                if fabs(scaleFrequency - majorFrequency) <= nearestFrequencyDifference {
                    nearestFrequencyDifference = fabs(scaleFrequency - majorFrequency)
                    nearestIndex = index
                    
                }
            }
            
            if nearestIndex >= majorPitchArray.count {
                return "\(majorPitchArray[nearestIndex])\(octaveCount + 1)"
                
            }else {
                
                return "\(majorPitchArray[nearestIndex])\(octaveCount)"
            }
            
            
        }
        
        
        
    }// funcEnd
    
    /// 音名 获取该音名的Index
    static func getPitchIndex(pitchName: String) -> Int? {
        
        for index in 0 ..< NoteNamesWithSharps.count {
            
            let pitch = NoteNamesWithSharps[index]
            
            if pitch == pitchName {
                
                return index
            }
        }


        
        return nil
        
    }// funcEnd
    
}

// MARK: - 和弦相关
extension GlobalMusicProperties {
    /// C大调和弦模型数组 优先级从后往前
    static private let MajorC_ChordModel = MajorUnknownChordModel.init(
        majorName: "C",
        chord: [
            ChordModel.init(chordName: "G7", chordNoteArray: ["G", "B", "D", "F"]),
            ChordModel.init(chordName: "Em", chordNoteArray: ["E", "G", "B"]),
            ChordModel.init(chordName: "Dm", chordNoteArray: ["D", "F", "A"]),
            ChordModel.init(chordName: "Am", chordNoteArray: ["A", "C", "E"]),
            ChordModel.init(chordName: "G", chordNoteArray: ["G", "B", "D"]),
            ChordModel.init(chordName: "F", chordNoteArray: ["F", "A", "C"]),
            ChordModel.init(chordName: "C", chordNoteArray: ["C", "E", "G"])
        ]
    )

    static let AllMajorChordArray: [MajorUnknownChordModel] = {
        var tmpArray: [MajorUnknownChordModel] = []
        
        for index in 0 ..< NoteNamesWithSharps.count {
            let pitchName = NoteNamesWithSharps[index]
            
            if pitchName == "C" {
                tmpArray.append(MajorC_ChordModel)
                
            }else {
                var MajorUnknownChordArray: [ChordModel] = []
                
                for chordModel in MajorC_ChordModel.chord {
                    
                    let targetPitchName = getPitchName(benchmarkPitchName: ToolClass.cutStringWithPlaces(chordModel.chordName, startPlace: 0, endPlace: 1), fromIndexTo: index)
                    let otherName: String = {
                        if chordModel.chordName.count > 1 {
                            return ToolClass.cutStringWithPlaces(chordModel.chordName, startPlace: 1, endPlace: chordModel.chordName.count)
                            
                        }else {
                            return ""
                            
                        }
                    }()
                    
                    // 目标和弦名
                    let targetChordName = targetPitchName + otherName
                    var targetChordContentArray: [String] = []
                    
                    for chordContent in chordModel.chordNoteArray {
                        targetChordContentArray.append(getPitchName(benchmarkPitchName: chordContent, fromIndexTo: index))
                        
                    }
                    
                    MajorUnknownChordArray.append(ChordModel.init(chordName: targetChordName, chordNoteArray: targetChordContentArray))
                    
                }
                
                tmpArray.append(MajorUnknownChordModel.init(majorName: pitchName, chord: MajorUnknownChordArray))
                
            }
            
            
        }
        
        return tmpArray
    }()
    
    /// 获取index距离后的音名
    static private func getPitchName(benchmarkPitchName: String, fromIndexTo: Int) -> String {
        
        var recordIndex = 0
        if self.NoteNamesWithSharps.contains(benchmarkPitchName) {
            for index in 0 ..< self.NoteNamesWithSharps.count {
                
                if self.NoteNamesWithSharps[index] == benchmarkPitchName {
                    recordIndex = index
                    
                }
            }
            
            let targetIndex = (recordIndex + fromIndexTo) % self.NoteNamesWithSharps.count
            
            return self.NoteNamesWithSharps[targetIndex]
            
        }else {
            return ""
            
        }
    }// funcEnd
    
    /// 通过NoteArry获取和弦序列
    static func getChordFrom(majorName: String, noteModelArray: [NoteModel]) -> [String] {
        
        let totalTime = AudioKitLogger.getAudioFileTotalTime()!
        let sectionTime = getSectionDuration()
        let sectionCount = 1 + Int((totalTime - timeDifferenceFromNowToNextBeat) / sectionTime) + 1
        
        let delayTime = getSectionDuration() - timeDifferenceFromNowToNextBeat
        
        var noteModelSectionArray: [[NoteModel]] = []
        
        for index in 0 ..< sectionCount {
            var tmpModelArray: [NoteModel] = []
            
            for noteModel in noteModelArray {
                
                if noteModel.startTime + delayTime >= Double(index) * sectionTime
                    &&
                    noteModel.getEndTime() + delayTime <= Double(index + 1) * sectionTime {
                    
                    tmpModelArray.append(noteModel)
                    
                }
                
            }
            
            noteModelSectionArray.append(tmpModelArray)
            
        }
        
        let majorUnknownChordModel: MajorUnknownChordModel! = {
            for majorChord in AllMajorChordArray {
                if majorChord.majorName == majorName {
                    return majorChord
                    
                }
                
            }
            
            return nil
            
        }()
        
        var resultArray: [String] = []
        for modelSectionArray in noteModelSectionArray {
            
            // 遍历majorUnknownChordModel 并计算匹配概率
            var percentageArray: [Double] = []
            
            for chord in majorUnknownChordModel.chord {
                
                var percentage = 0.0
                // 每小节的noteModel
                for noteModel in modelSectionArray {
                    
                    if chord.chordNoteArray.contains(noteModel.pitchName) == true {
                        percentage += noteModel.duration
                        
                    }
                    
                    
                }
                
                percentageArray.append(percentage)

            }
            
            // 从匹配概率数组挑出最大的
            var maxIndex = 0
            var maxChordPercentage = 0.0

            for index in 0 ..< percentageArray.count {
                let chordPercentage = percentageArray[index]
                
                if chordPercentage >= maxChordPercentage{
                    maxChordPercentage = chordPercentage
                    maxIndex = index
                }
            }
            
            
            resultArray.append(majorUnknownChordModel.chord[maxIndex].chordName)
            

        }
        
        return resultArray
    }// funcEnd
    
}


