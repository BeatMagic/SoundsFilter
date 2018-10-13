//
//  FrameStandard.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/15.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class FrameStandard: NSObject {
    /// 按钮通用宽高
    static let genericButtonSideLength: CGFloat = 60
    
    /// 按钮通用Y
    static let genericButtonY: CGFloat = (ToolClass.getScreenHeight() - FrameStandard.genericButtonSideLength) / 4 * 3
    
    /// 一秒钟时进度条的宽
    static let OneSecondProgressWidth = (ToolClass.getScreenWidth() - genericButtonSideLength / 4 * 2) / 27
    
    /// 游标宽高
    static let cursorSideLength: CGFloat = genericButtonSideLength / 6
    
}
