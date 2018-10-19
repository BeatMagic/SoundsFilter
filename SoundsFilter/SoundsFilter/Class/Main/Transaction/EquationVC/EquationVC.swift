//
//  EquationVC.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/15.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class EquationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var tmpTimeArray: [Double] = []
        var tmpFrequencyArray: [Double] = []
        
        
        var currentTime: Double = 0
        
        for frequency in GlobalMusicProperties.recordFrequencyArray {
            
            if let tmpFrequency = frequency {
                tmpTimeArray.append(currentTime)
                tmpFrequencyArray.append(tmpFrequency)
            }
            
            currentTime += GlobalMusicProperties.getDetectFrequencyDuration()
        }

        
        self.view.addSubview(EquationView.init(
            xArray: tmpTimeArray,
            yArray: tmpFrequencyArray,
            totalTime: AudioKitLogger.getAudioFileTotalTime()!
        ))
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

}
