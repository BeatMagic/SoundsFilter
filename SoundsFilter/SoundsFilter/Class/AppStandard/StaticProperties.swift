//
//  StaticProperties.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class StaticProperties: NSObject {
    /// 图片文件名集合
    enum ImageName: String {
        /// 返回
        case back = "back"
        
        /// 添加
        case add = "add"
        
        /// 录制
        case record = "record"
        
        /// 停止录制
        case stopped = "stopped"
        
        /// 播放
        case play = "play"
        
        /// 停止播放
        case stopPlaying = "stop_playing"
        
        /// 游标
        case cursor = "down_arrow"
        
    }
    
    /// 记录页面状态
    enum RecordVCStatus {
        /// 初始
        case Initial
        
        /// 录制中
        case Recording
        
    }
    
    /// 编辑页面状态
    enum EditVCStatus {
        /// 初始
        case Initial
        
        /// 播放中
        case Playing
    }
}
