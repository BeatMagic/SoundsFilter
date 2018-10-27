//
//  EquationVC.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/15.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class EquationVC: UIViewController {
    @IBOutlet var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var noteString = ""
        
        let tmpModelSectionArray = GlobalMusicProperties.tmpModelSectionArray
        
        
        for index in 0 ..< tmpModelSectionArray.count {
            
            let tmpModelSection = GlobalMusicProperties.tmpModelSectionArray[index]
            
            noteString += "\n\n第\(String(index))小节. 结束时间: \(GlobalMusicProperties.tmpTimelineArray[index].roundTo(places: 2))\n"
            
            for note in tmpModelSection {
                noteString += "音高\(String(note.pitchName)), 开始时间\(String(note.startTime.roundTo(places: 2))), 持续时间\(String(note.duration.roundTo(places: 2)))\n"
                
                
            }
            
            
            
            
        }
        
        
        self.textView.text = noteString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var timeLineStrng = ""
//
//        for index in 0 ..< GlobalMusicProperties.tmpTimelineArray.count {
//            let tmpTimeline = GlobalMusicProperties.tmpTimelineArray[index]
//            let string = "第\(String(index))结束时间."
//            timeLineStrng += string
//
//        }
        
        
        
        

//        var tmpTimeArray: [Double] = []
//        var tmpFrequencyArray: [Double] = []
//        
//        
//        var currentTime: Double = 0
//        
//        for frequency in GlobalMusicProperties.recordFrequencyArray {
//            
//            if let tmpFrequency = frequency {
//                tmpTimeArray.append(currentTime)
//                tmpFrequencyArray.append(tmpFrequency)
//            }
//            
//            currentTime += GlobalMusicProperties.getDetectFrequencyDuration()
//        }
//
//        
//        self.view.addSubview(EquationView.init(
//            xArray: tmpTimeArray,
//            yArray: tmpFrequencyArray,
//            totalTime: AudioKitLogger.getAudioFileTotalTime()!
//        ))
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

}
