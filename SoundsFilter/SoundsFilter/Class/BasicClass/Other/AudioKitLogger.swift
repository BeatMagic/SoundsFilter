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
    static private let tracker: AKFrequencyTracker = AKFrequencyTracker.init(mic, peakCount: 2)
    
    static private let silence = AKBooster(tracker, gain: 0)
    
    // MARK: - 记录相关
    /// 记录器
    static private var recorder: AKNodeRecorder?
    
    /// 录音信息
    static private var tape: AKAudioFile?
    
    /// 播放器
    static private var player: AKPlayer?
    
    /// 主混合器
    static private var mainMixer: AKMixer?
    
    /// 播放完成回调闭包
    static private var completionHandler: (() -> Void)?
    
    /// 调音需要
    static private var pitchShifter: AKPitchShifter?
    
    /// Sequencer
    static private var finalSequencer: AKSequencer?
    
    /// sampler混合器
    static var samplerMixer: AKMixer?
    
    /// 播放混合器
    static private var playMixer: AKMixer = AKMixer.init()
    
    static private var midiSamplerArray: [AKMIDISampler] = []
    
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
            AKSettings.defaultToSpeaker = false
            
            self.recorder = try! AKNodeRecorder(node: mic)
            
            if let file = recorder!.audioFile {
                self.player = AKPlayer(audioFile: file)
            }
            
            self.player!.isLooping = false
            
            self.pitchShifter = AKPitchShifter.init(self.player!)
            self.pitchShifter!.rampDuration = 0
            
            self.playMixer.connect(input: pitchShifter)
            
            let moogLadder = AKMoogLadder.init(self.playMixer, cutoffFrequency: 5000
                , resonance: 0.5)
            
            self.mainMixer = AKMixer(silence, moogLadder)

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
        
        
        try! AudioKit.stop()
        
        AKSettings.defaultToSpeaker = true
        
        try! AudioKit.start()
        
    }
    
    
    
    /// 播放录制好的文件
    static func playFile(action: @escaping (() -> Void)) -> Void {
        PlayerTimer.initializeTimer()
        AudioKitLogger.samplerMixer!.volume = 0
        self.finalSequencer!.play()
        
        let delayTime = GlobalMusicProperties.getSectionDuration() - GlobalMusicProperties.timeDifferenceFromNowToNextBeat
        
        DelayTask.createTaskWith(workItem: {
            self.player!.play()
            action()
            
        }, delayTime: delayTime)
        
    }
    
    /// 停止播放
    static func stopPlayingFile() -> Void {
        
        self.player!.stop()
        PlayerTimer.destroyTimer()
        self.finalSequencer!.stop()
        self.finalSequencer!.rewind()
        
        self.finalSequencer = nil
        DelayTask.cancelAllWorkItems()
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
        self.finalSequencer = AKSequencer.init()
        self.samplerMixer = AKMixer.init()

        let toneNumArray = [50, 0, 89]
        let amplitudeArray = [-90, -1.5, -21.3]
        
        
        
        for index in 0 ..< toneNumArray.count {
            
            let sampler = AKMIDISampler()
            
            if index == 1 {
                try! sampler.loadMelodicSoundFont("FullGrandPiano", preset: toneNumArray[index])


            }else {
                try! sampler.loadMelodicSoundFont("GeneralUser", preset: toneNumArray[index])

            }
            
            sampler.amplitude = amplitudeArray[index]
            
            
            _ = finalSequencer!.newTrack()
            finalSequencer!.tracks[index].setMIDIOutput(sampler.midiIn)
            
            self.samplerMixer!.connect(input: sampler)
            
            self.midiSamplerArray.append(sampler)

        }
        
        
        playMixer.connect(input: self.samplerMixer!)
        
        var lastClipBeats = 0.0
        finalSequencer!.setLength(AKDuration(beats: 4 * finalChordNameArray.count))
        finalSequencer!.setTempo(GlobalMusicProperties.musicBPM)
        
        for index in 0 ..< finalChordNameArray.count {
            
            let chordName = finalChordNameArray[index]
            let temp = AKSequencer.init()
            temp.loadMIDIFile(chordName)
            
            let tempTracks = temp.tracks
            let tracks = finalSequencer!.tracks
            assert(tempTracks.count == tracks.count)
            for trackIndex in 0 ..< tracks.count {
                
                let noteDataArray = tempTracks[trackIndex].getMIDINoteData()
                
                for noteData in noteDataArray {
                    if noteData.duration == AKDuration.init(beats: 0.0) {
                        continue
                        
                    }

                    var setNoteData = noteData
                    let oldBeat = noteData.position.beats
                    let newBeat = oldBeat + lastClipBeats
                    setNoteData.position = AKDuration(beats: newBeat)
                    tracks[trackIndex].add(midiNoteData: setNoteData)
                }
            }
            
            lastClipBeats += temp.length.beats
            
        }
        
//        for t in finalSequencer!.tracks{
//            print("track==========================================")
//            for nt in t.getMIDINoteData(){
//                print(nt)
//            }
//        }
      
    }// funcEnd
    
    
}
