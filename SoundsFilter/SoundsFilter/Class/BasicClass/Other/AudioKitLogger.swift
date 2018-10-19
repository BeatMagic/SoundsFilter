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
    /// 子线程
    static let audioKitQueue = DispatchQueue.init(label: "audioKitQueue",
                                                  qos: .userInteractive,
                                                  attributes: .concurrent,
                                                  autoreleaseFrequency: .never,
                                                  target: nil)
    
    // MARK: - 分析相关
    /// 麦克风
    static private let mic: AKMicrophone = {
        let tmpMic = AKMicrophone.init()
        
        return tmpMic
    }()
    
    /// 跟踪器
    static private let tracker: AKFrequencyTracker = AKFrequencyTracker.init(mic, peakCount: 3)
    
    static private let silence = AKBooster(tracker, gain: 0)
    
    // MARK: - 记录相关
    /// 麦克混合器
    static private let micMixer: AKMixer = AKMixer(mic)
    
    /// 麦克加速器
    static private let micBooster: AKBooster = AKBooster(micMixer)
    
    /// 记录器
    static private var recorder: AKNodeRecorder?
    
    /// 录音信息
    static private var tape: AKAudioFile?
    
    /// 播放器
    static var player: AKPlayer?
    
    /// 主混合器
    static private var mainMixer: AKMixer?
    
    /// 播放完成回调闭包
    static private var completionHandler: (() -> Void)?
    
    /// 调音需要
    static private var pitchShifter: AKPitchShifter?
    
    
    
    static private let finalSequencer = AKSequencer.init()
    /// 播放混合器
    static private var playMixer: AKMixer = AKMixer.init()
    
    
    
}

// MARK: - 外部接口
extension AudioKitLogger {
    /// 初始化
    static func initializeLogger() -> Void {
        self.audioKitQueue.async {
            AKAudioFile.cleanTempDirectory()
            AKSettings.bufferLength = .medium
            
            do {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } catch {
                AKLog("Could not set session category.")
            }
            
            // 初始设置
            AKSettings.defaultToSpeaker = true
            micBooster.gain = 0
            
            self.recorder = try! AKNodeRecorder(node: micMixer)
            
            if let file = recorder!.audioFile {
                self.player = AKPlayer(audioFile: file)
            }
            
            self.player!.isLooping = false
            
            self.pitchShifter = AKPitchShifter.init(self.player!)
            self.pitchShifter!.rampDuration = 0
            
            self.mainMixer = AKMixer(micBooster, silence)
            
            AudioKit.output = mainMixer!
            
            
            do {
                try AudioKit.start()
            } catch {
                AKLog("AudioKit did not start!")
            }
            
        }
        
    }
    
    /// 重置
    static func resetLogger() -> Void {
        
        if let existingPlayer = self.player {
            existingPlayer.stop()
            
            do {
                try self.recorder!.reset()
                
            } catch { AKLog("Errored resetting.") }
            
            
            do {
                try AudioKit.stop()
            } catch {
                AKLog("AudioKit did not start!")
            }
            
            self.player = nil
            self.mainMixer = nil
            self.tape = nil
            self.recorder = nil
            AKAudioFile.cleanTempDirectory()
            
            
        }
    }
    
    /// 获取播放文件时长
    static func getAudioFileTotalTime() -> Double? {
        
        if let player = self.player {
            return player.duration
            
        }else {
            return nil
            
        }
    }
    
    /// 设置播放完成后的回调
    static func setPlayerCompletionHandler(completionHandler: @escaping (() -> Void)) -> Void {
        self.completionHandler = completionHandler
        self.player!.completionHandler = self.playingEnded
        
    }
    
    static private func playingEnded() {
        if let completionHandler = self.completionHandler {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
}

// MARK: - 频率相关
extension AudioKitLogger {
    /// 获取实时声音频率
    static func getRealtimeNote() -> Double? {
        
        // 当音量大于0.1时
        if self.tracker.amplitude >= 0.1
            &&
            self.tracker.frequency > GlobalMusicProperties.VocalFrequencyInterval.first!
            &&
            self.tracker.frequency < GlobalMusicProperties.VocalFrequencyInterval.last!
            {
                
            return self.tracker.frequency
        }

        return nil
    }
    

}

// MARK: - 记录器相关
extension AudioKitLogger {
    /// 开始录制
    static func startRecording() -> Void {
        
        self.audioKitQueue.async {
            
            
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder!.record()
            } catch { AKLog("Errored recording.") }
        }
    }
    
    /// 停止录制并返回文件名
    static func stopRecording() -> Void {
        self.tape = self.recorder!.audioFile!
        self.player!.load(audioFile: self.tape!)
        
        if let _ = self.player!.audioFile?.duration {
            recorder!.stop()
            self.tape!.exportAsynchronously(name: "TempTestFile.m4a",
                                            baseDir: .documents,
                                            exportFormat: .m4a) {_, exportError in
                                                if let error = exportError {
                                                    AKLog("Export Failed \(error)")
                                                } else {
                                                    AKLog("Export succeeded")
                                                }
            }
        }
        
    }
    
    
    
    /// 播放录制好的文件
    static func playFile() -> Void {
        
        playMixer.connect(input: pitchShifter)
        
        AudioKit.output = playMixer
        
        let delayTime = GlobalMusicProperties.getSectionDuration() - GlobalMusicProperties.timeDifferenceFromNowToNextBeat
        
        finalSequencer.play()
        
        
        DelayTask.createTaskWith(workItem: {
            self.player!.play()
        }, delayTime: delayTime)
        

    }
    
    /// 停止播放
    static func stopPlayingFile() -> Void {
        self.player!.stop()
        finalSequencer.stop()
    }
    
    /// 设置pitchShifter
    static func setPitchShifter(shift: Double) -> Void {
        self.pitchShifter!.shift = shift
    }// funcEnd
}

// MARK: - 伴奏相关
extension AudioKitLogger {
    /// 初始化Sequencer
    static func initializeSequencer(finalChordNameArray: [String]) -> Void {
        
        
        
        for index in 0 ..< finalChordNameArray.count {
            

            let chordName = finalChordNameArray[index]
            
            if index == 0 {
                finalSequencer.loadMIDIFile(chordName)
                
            }else {
//                finalSequencer.addMIDIFileTracks(chordName, useExistingSequencerLength: false)
                #warning("待修复")
                
                
                
            }
            
//            finalSequencer.addMIDIFileTracks(chordName)

        }
        
        
        finalSequencer.setTempo(GlobalMusicProperties.musicBPM)
        
        
        let array = [0, 33, 5, 108, 90, 101, 9]
        
        for index in 0 ..< array.count {
            let serialNumber = array[index]
            
            let sampler = AKMIDISampler()
            try! sampler.loadMelodicSoundFont("GeneralUser", preset: serialNumber)
            
            finalSequencer.tracks[index].setMIDIOutput(sampler.midiIn)
            
            playMixer.connect(input: sampler)
        }
        
    }// funcEnd
    
    
}
