//
//  EditViewController.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

private var currentTimeContext = 0

class EditViewController: UIViewController {
    
// MARK: - 状态属性
    /// 是否在记录中
    private var recordStatus: StaticProperties.EditVCStatus = .Initial
    
    /// 调整之后的数组
    private var finalNoteArray: [NoteModel] = []
    
    private var firstFrequencyModelArray: [FrequencyDurationModel] = []
    
    /// 大调名
    private var majorName: String = ""
    
    /// 和弦数组
    private var finalChordNameArray: [String] = []
    
    
// MARK: - UI
    @IBOutlet var effectiveNoteLabel: UILabel!
    
    @IBOutlet var majorLabel: UILabel!
    
    @IBOutlet var sectionChordLabel: UILabel!
    
    /// 进度条
    private var playProgressBar: PlayProgressBar? {
        didSet {
            if let playProgressBar = self.playProgressBar {
                self.view.addSubview(playProgressBar)

            }
        }
    }
    
    
    /// 播放按钮
    private lazy var playButton: UIButton = {
        let tmpButton = UIButton.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: FrameStandard.genericButtonSideLength / 3 * 2,
                height: FrameStandard.genericButtonSideLength / 3 * 2
            )
        )
        
        tmpButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
        tmpButton.center = CGPoint.init(x: ToolClass.getScreenWidth() / 2,
                                        y: ToolClass.getScreenHeight() / 5 * 4)
        tmpButton.addTarget(self, action: #selector(self.clickRecordButtonEvent), for: .touchUpInside)
        
        self.view.addSubview(tmpButton)
        
        return tmpButton
    }()
    
    /// 返回ButtonItem
    private lazy var backButtonItem: UIBarButtonItem = {
        let tmpButton = UIButton.init(frame:
            CGRect.init(
                x: 0,
                y: 0,
                width: 25,
                height: 25
            )
        )
        
        tmpButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        tmpButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        tmpButton.setImage(
            UIImage.init(named: StaticProperties.ImageName.back.rawValue),
            for: .normal
        )
        
        tmpButton.addTarget(self, action: #selector(self.clickBackButtonEvent), for: .touchUpInside)
        
        return UIBarButtonItem.init(customView: tmpButton)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let totalTime = AudioKitLogger.getAudioFileTotalTime() {
            self.playProgressBar = PlayProgressBar.init(totalTimeLength: totalTime)
            self.playProgressBar!.didSetBracketsLoctionAction = {
                self.matchSelectSectionsMajor()
            }
        }
        
        
        AudioKitLogger.setPlayerCompletionHandler {
            self.recordStatus = .Initial
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
            AudioKitLogger.stopPlayingFile()
            self.playProgressBar!.cursorCancelAnimation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setData()
        self.setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let playProgressBar = self.playProgressBar {
            playProgressBar.removeFromSuperview()
            
        }
        
        self.playProgressBar = nil
        AudioKitLogger.setPlayerCompletionHandler {
            
        }
        
        if self.recordStatus == .Playing {
            self.clickRecordButtonEvent()
            
        }
    }
}

// MARK: - 设置函数封装
extension EditViewController {
    func setData() -> Void {

        
    }
    
    func setUI() -> Void {
        self.navigationItem.leftBarButtonItem = self.backButtonItem
        self.playButton.tag = 1
        
        
    }
    
    /// 计算选中小节大调并存储
    func matchSelectSectionsMajor() -> Void {
        print("计算选中小节大调并存储")
        
        self.finalNoteArray = []
        self.firstFrequencyModelArray = []
        GlobalMusicProperties.frequencyModelArray = []
        
        let tmpFinalNoteArray =
        

        self.finalNoteArray = self.processFrequencyArray()
        
        #warning("测试")
        DispatchQueue.main.async {
            var text = ""
            
            for noteModel in self.finalNoteArray {
                text += noteModel.pitchName
                text += ","
            }
            
            self.effectiveNoteLabel.text = text
            
        }
        #warning("测试结束")
        
        
        // 第一步提纯
        self.firstFrequencyModelArray = MusicConverter.purifyFrequencyModel(frequencyArray: GlobalMusicProperties.recordFrequencyArray)
        
       
        var frequencyModelArray : [[FrequencyDurationModel]] = []
        
        for finalNote in self.finalNoteArray {
            let startTime = finalNote.startTime
            let endTime = finalNote.getEndTime()
            var tmpFrequencyModelarray: [FrequencyDurationModel] = []
            
            
            for frequencyModel in self.firstFrequencyModelArray {
                if frequencyModel.startTime! >= startTime!
                    && frequencyModel.endTime! <= endTime {
                    
                    tmpFrequencyModelarray.append(frequencyModel)
                    
                }
                
            }
            
            frequencyModelArray.append(tmpFrequencyModelarray)
            
            
        }
        
        GlobalMusicProperties.frequencyModelArray = frequencyModelArray
        
        if let bracketsSelectedTime = GlobalMusicProperties.bracketsSelectedTime {
            
            if bracketsSelectedTime.upperBound ==  bracketsSelectedTime.lowerBound {
                return
                
            }
            
            var selecetNoteArray: [NoteModel] = []
            for index in 0 ..< self.finalNoteArray.count {
                
                let finalNoteModel = self.finalNoteArray[index]
                
                if bracketsSelectedTime.contains(finalNoteModel.getEndTime())
                    && GlobalMusicProperties.NoteNamesWithSharps.contains(finalNoteModel.pitchName) == false {
                    selecetNoteArray.append(finalNoteModel)
                    
                }
                
            }
            
            
            // 获取近似大调
            let thisTimeMajorName = GlobalMusicProperties.getApproximateMajor(noteModelArray: selecetNoteArray)
            
            #warning("测试")
            DispatchQueue.main.async {
                self.majorLabel.text = thisTimeMajorName
                
            }
            
            #warning("测试结束")
            
            let frequencyModelArrayWithTime = GlobalMusicProperties.frequencyModelArray
            
            var adjustIndexArray: [Double] = []
            
            var timelineArray: [(Double, Double)] = []
            
            var finalPitchNoteArray: [NoteModel] = []
            
            let queueGroup = DispatchGroup.init()
            
            let calculatQueue = DispatchQueue(label: "calculatQueue")
            calculatQueue.async(group: queueGroup, execute: {
                for selecetNoteIndex in 0 ..< selecetNoteArray.count {
                    let selecetNote = selecetNoteArray[selecetNoteIndex]
                    
                    for finalNoteIndex in 0 ..< self.finalNoteArray.count {
                        let frequencyModelArray = frequencyModelArrayWithTime[finalNoteIndex]
                        // 找到对应的频率数组
                        if selecetNoteIndex == finalNoteIndex {
                            
                            var summation = 0.0
                            for frequencyModel in frequencyModelArray {
                                summation += MusicConverter.getFrameY(frequency: frequencyModel.frequency
                                )
                                
                            }
                            // 纵坐标平均数
                            let average = summation / Double(frequencyModelArray.count)
                            
                            // 近似大调音阶
                            let finalPitch = GlobalMusicProperties.getNearestMajorPitch(majorName: thisTimeMajorName, pitchName: selecetNote.pitchName, average: average)
                            
                            // 近似大调音名
                            let finalPitchName = ToolClass.cutStringWithPlaces(finalPitch, startPlace: 0, endPlace: finalPitch.count - 1)
                            
                                
                            finalPitchNoteArray.append(NoteModel.init(
                                    pitchName: finalPitchName,
                                    startTime: selecetNote.startTime,
                                    duration: selecetNote.duration
                                ))
                            
                            
                            let finalPitchNameIndex = GlobalMusicProperties.getPitchIndex(pitchName: finalPitchName)
                            
                            if finalPitchNameIndex != nil {
                                
                                let standardFrequency = MusicConverter.getFrequencyFrom(pitchName: finalPitch)
                                var adjustIndex = MusicConverter.getFrameY(frequency: standardFrequency) - average
                                
                                if fabs(adjustIndex) > 1 {
                                    if adjustIndex <= -1 {
                                        adjustIndex += 2

                                    }else {
                                        adjustIndex -= 2

                                    }

                                }
                                
                                adjustIndexArray.append(adjustIndex)
                                timelineArray.append((selecetNote.startTime, selecetNote.getEndTime()))
                            }
                            
                            

                            
                            
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
            })
            
            let group = DispatchGroup.init()
            group.notify(queue: calculatQueue) {
                GlobalMusicProperties.adjustIndexArray = adjustIndexArray
                GlobalMusicProperties.timelineArray = timelineArray
                
                //                self.finalNoteArray = finalPitchNoteArray
                self.majorName = thisTimeMajorName
                
                /// 切割音符
                let tmpCutFinalPitchNoteArray = self.cutNoteForSection(finalPitchNoteArray)

                let preliminaryChordNameArray = GlobalMusicProperties.getChordFrom(majorName: self.majorName, noteModelArray: tmpCutFinalPitchNoteArray)
                print(preliminaryChordNameArray)
                
                var finalChordNameArray: [String] = []
                
                for index in 0 ..< preliminaryChordNameArray.count {
                    let preliminaryChordName = preliminaryChordNameArray[index]
                    
                    finalChordNameArray.append("\(preliminaryChordName)_1")
                    
                    
                }
                
                self.finalChordNameArray = finalChordNameArray
                
                
                #warning("测试")
                DispatchQueue.main.async {
                    var testText = ""
                    
                    for finalChordName in self.finalChordNameArray {
                        testText += "\(finalChordName), "
                        
                    }
                    
                    testText += "|| "
                    
                    var finalPitchText = ""
                    
                    for finalPitch in finalPitchNoteArray {
                        
                        
                        
                        finalPitchText += finalPitch.pitchName
                        finalPitchText += ","
                        
                        
                        
                    }
                    
                    self.sectionChordLabel.text = testText
                    let _ = self.sectionChordLabel.setAutoFitHeight(x: 0, y: 300, width: ToolClass.getScreenWidth())
                    
                }
                
                #warning("测试结束")
            }
            
            
            
        }
        
    }// funcEnd
    
    /// 切割音符
    func cutNoteForSection(_ noteArray: [NoteModel]) -> [NoteModel] {
        let totalTime = AudioKitLogger.getAudioFileTotalTime()!
        let delayTime = GlobalMusicProperties.timeDifferenceFromNowToNextBeat
        let sectionTime = GlobalMusicProperties.getSectionDuration()
        let sectionCount = 1 + Int((totalTime - delayTime) / sectionTime) + 1
        
        var resultArray: [NoteModel] = []
        

        
        for index in 0 ..< sectionCount {
            let startTime: Double = {
                if index == 0 {
                    return 0
                    
                }else {
                    return Double(index - 1) * sectionTime + delayTime
                    
                }
                
            }()
            
            let endTime: Double = {
                if index == 0 {
                    return delayTime
                    
                }else if index == sectionCount - 1 {
                    return totalTime - Double(sectionCount - 2) * sectionTime - delayTime
                    
                }else {
                    return Double(index) * sectionTime + delayTime
                    
                }
                
            }()
            
            let thisSectionTime: Double = {
                if index == 0 {
                    return delayTime
                    
                }else if index == sectionCount {
                    return totalTime - Double(sectionCount - 2) * sectionTime - delayTime
                    
                }else {
                    return sectionTime
                    
                }
                
            }()
            
            for noteModel in noteArray {
                
                if noteModel.startTime >= startTime
                    && noteModel.startTime <= endTime {
                    
                    if noteModel.getEndTime() > endTime { // 需要切割的情况
                        let duration1 = thisSectionTime - (noteModel.startTime - startTime)
                        let duration2 = noteModel.duration - duration1
                        
                        let prevNoteModel = NoteModel.init(pitchName: noteModel.pitchName, startTime: noteModel.startTime, duration: duration1)
                        let nextNoteModel = NoteModel.init(pitchName: noteModel.pitchName, startTime: endTime, duration: duration2)
                        
                        resultArray.append(prevNoteModel)
                        
                        if nextNoteModel.duration > sectionTime {
                            let nextNoteModel1 = NoteModel.init(
                                pitchName: nextNoteModel.pitchName,
                                startTime: nextNoteModel.getEndTime(),
                                duration: sectionTime
                            )
                            
                            let nextNoteModel2 = NoteModel.init(
                                pitchName: nextNoteModel.pitchName,
                                startTime: nextNoteModel.getEndTime() + sectionTime,
                                duration: nextNoteModel.duration - sectionTime
                            )
                            resultArray.append(nextNoteModel1)
                            resultArray.append(nextNoteModel2)
                            
                        }else {
                            resultArray.append(nextNoteModel)
                            
                        }
                        
                    }else { // 不需要切割的情况
                        resultArray.append(noteModel)
                        
                    }
                    
                }
                
            }
            
        }
        

        
        return resultArray
        
    }// funcEnd
    
    /// 对频率数组做出处理
    func processFrequencyArray() -> [NoteModel] {
        var noteModelArray: [NoteModel] = []
        
        if GlobalMusicProperties.recordFrequencyArray == [] {
            return noteModelArray
            
        }
        
        let frequencyArray = GlobalMusicProperties.recordFrequencyArray
        var currentTime: Double = 0
        
        for frequency in frequencyArray {
            if frequency != nil { // 存在有效频率的情况
                let frequencyPitchName = MusicConverter.getApproximatePitch(frequency: frequency!)
                
                if let lastModel = noteModelArray.last {
                    
                    if lastModel.pitchName == frequencyPitchName {
                        
                        lastModel.duration += GlobalMusicProperties.getDetectFrequencyDuration()
                        
                    }else {
                        let model = NoteModel.init(pitchName: frequencyPitchName, startTime: currentTime, duration: GlobalMusicProperties.getDetectFrequencyDuration())
                        model.duration = GlobalMusicProperties.getDetectFrequencyDuration()
                        noteModelArray.append(model)
                        
                    }
                    
                }else {
                    let model = NoteModel.init(pitchName: frequencyPitchName, startTime: currentTime, duration: GlobalMusicProperties.getDetectFrequencyDuration())
                    
                    noteModelArray.append(model)
                    
                }
                
                
            }
            
            currentTime += GlobalMusicProperties.getDetectFrequencyDuration()
        }

        var resultModelArray: [NoteModel] = []
        
        for noteModel in noteModelArray {
            if noteModel.duration >= GlobalMusicProperties.getMinNoteDuration() {
                resultModelArray.append(noteModel)
                
            }
        }
        
        return resultModelArray
    }// funcEnd
}

// MARK: - 点击事件
extension EditViewController {
    /// 点击返回
    @objc func clickBackButtonEvent() -> Void {
        self.dismiss(animated: true) {
            
        }
        
    }// funcEnd
    
    /// 点击播放/停止
    @objc func clickRecordButtonEvent() -> Void {
        switch self.recordStatus {
        case .Initial:
            AudioKitLogger.initializeSequencer(finalChordNameArray: self.finalChordNameArray)
            
            
            self.recordStatus = .Playing
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.stopPlaying.rawValue), for: .normal)
            
            
            
            
            AudioKitLogger.playFile(action: {
                self.playProgressBar!.cursorAnimation()
            })
            
        case .Playing:
            AudioKitLogger.stopPlayingFile()
            
            self.recordStatus = .Initial
            self.playButton.setImage(UIImage.init(named: StaticProperties.ImageName.play.rawValue), for: .normal)
            
            if self.playProgressBar != nil {
                self.playProgressBar!.cursorCancelAnimation()
                
            }
            
        }
        
        
        
    }// funcEnd
}
