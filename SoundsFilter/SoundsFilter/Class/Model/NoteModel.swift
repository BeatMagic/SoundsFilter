//
//  NoteModel
//  SoundsFilter
//
//  Created by X Young. on 2018/10/16.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class NoteModel: NSObject {
    
    /// 音阶
    let pitchName: String!
    
    /// 开始时间
    let startTime: Double!
    
    /// 持续时间
    var duration: Double!

    init(pitchName: String!, startTime: Double!, duration: Double) {
        self.pitchName = pitchName
        self.startTime = startTime
        self.duration = duration
        
        super.init()

    }
    
    /// 获取结束时间
    func getEndTime() -> Double {
        return self.startTime + self.duration
        
    }// funcEnd
}
