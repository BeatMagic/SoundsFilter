//
//  EquationView.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/15.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import SwiftCharts

class EquationView: UIView {
    
    init(xArray: [Double], yArray: [Double], totalTime: Double) {
        let frame = CGRect(x: 0, y: 80, width: ToolClass.getScreenWidth(), height: ToolClass.getScreenHeight() - 80)
        super.init(frame: frame)
        
        
        
        var pointArray: [(Double, Double)] = []
        
        var frequencyArray: [String] = []
        
        for frequency in yArray {
            frequencyArray.append(MusicConverter.getApproximatePitch(frequency: frequency))
        }
        
        
        var index = 0
        for y in yArray {
            
            let tmpY = MusicConverter.getFrameY(frequency: y)
            
            
            pointArray.append((
                xArray[index], tmpY
            ))
            
            GlobalMusicProperties.xxxx.append(tmpY)

            index += 1
        }
        
        
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(
                from: 0,
                to: totalTime,
                by: GlobalMusicProperties.getDetectFrequencyDuration()
            ),
            yAxisConfig: ChartAxisConfig(
                from: 2,
                to: MusicConverter.getFrameY(frequency: 1244),
                by: (MusicConverter.getFrameY(frequency: 1244) - 2) / Double(GlobalMusicProperties.PitchFrequencyModelArray.count)
            )
        )
        
        print(frequencyArray)
        
        
//
//        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
//        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
//
//        // 创建坐标系
//        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
//        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
//
        let tmpFrame = CGRect.init(x: 0, y: 0, width: self.getWidth(), height: self.getHeight())
        
        let lineChart = LineChart(
            frame: tmpFrame,
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            lines: [
                (chartPoints: pointArray,
                 color: UIColor.red),
            ]
        )
        
        let tmpView = lineChart.view
//        tmpView.transform = CGAffineTransform.init(rotationAngle: .pi / 2)
        
        self.addSubview(tmpView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
