//
//  ToolClass.swift
//  BirthdayManager
//
//  Created by X Young. on 2017/10/31.
//  Copyright © 2017年 X Young. All rights reserved.
//

import UIKit

public class ToolClass: NSObject {
    
    /// 求两点间距离
    static func getDistance(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return sqrt(pow((point1.x - point2.x), 2) + pow((point1.y - point2.y), 2))
        
    }
    
    /// 给定两个点 获得该直线方程
    static func getEquationFrom(point1: CGPoint, point2: CGPoint) -> [CGFloat] {
        
        // y = a * x + b
        let a = (point1.y - point2.y) / (point1.x - point2.x)
        
        let b = point1.y - a * point1.x
        
        return [a, b]
    }
    
    /// 给定两个点和一个View 获得两点所连线段是否过View
    static func judgeTwoPointsSegmentIsPassView(point1: CGPoint, point2: CGPoint, view: UIView) -> Bool {
        // 系数数组 [a, b]
        let coefficientArray = self.getEquationFrom(point1: point1, point2: point2)
        let a = coefficientArray[0]
        let b = coefficientArray[1]
        
        // view的上宽和下宽的Y
        let y1 = view.frame.origin.y
        let y2 = y1 + view.frame.height
        
        // 获得解
        let x1 = (y1 - b) / a
        let x2 = (y2 - b) / a
        
        var tmpPoint1: CGPoint
        var tmpPoint2: CGPoint
        
        
        if point1.x > point2.x {
            tmpPoint1 = point2
            tmpPoint2 = point1
            
        }else {
            tmpPoint1 = point1
            tmpPoint2 = point2
            
        }
        
        // View的x区间
        let minX = view.frame.origin.x
        let maxX = minX + view.frame.width
        
        if (x1 >= minX && x1 <= maxX && x1 >= tmpPoint1.x && x1 <= tmpPoint2.x)
            ||
            (x2 >= minX && x2 <= maxX && x2 >= tmpPoint1.x && x2 <= tmpPoint2.x ) {
            
            return true
            
        }else if view.frame.contains(point1) || view.frame.contains(point2) {
            return true
            
        }else {
            return false
            
        }
        
        
        
    }
    
    
    /// 3.2 字符串的剪切与拼接
    static func cutStringWithPlaces(_ dealString: String, startPlace: Int, endPlace: Int) -> String {
        let startIndex = dealString.index(dealString.startIndex, offsetBy: startPlace)
        let endIndex = dealString.index(startIndex, offsetBy: endPlace - startPlace)
        
        return String(dealString[startIndex ..< endIndex])
    }
    
    // MARK: - GCD相关
    /// 1.GCD回到主线程
    static func GCDMain() -> Void {
        // 1.GCD回到主线程
        DispatchQueue.main.async {
            
        }
        
    }
    
    /// 2.Dispatch Group的使用
    static func dispatchGroup() -> Void {
        let queueGroup = DispatchGroup.init()
        
        for i in 0 ..< 9 {
            let basicQueue = DispatchQueue(label: "basicQueue")
            basicQueue.async(group: queueGroup, execute: {
                // 进行操作
                printWithMessage("这是\(i)")
            })
        }
        
        queueGroup.notify(queue: DispatchQueue.main) {
            printWithMessage("最后一步")
        }
        
    }
    
    /// 3.Dispatch Barrier的使用
    static func dispatchBarrier() -> Void {
        let growUpQueue = DispatchQueue(label: "growUpQueue")
        growUpQueue.async {
            printWithMessage("1")
        }
        
        growUpQueue.async(group: nil, qos: .default, flags: .barrier) {
            printWithMessage("虎落平阳")
        }
        
        growUpQueue.async {
            printWithMessage("东山再起")
        }
    }
    
    /// 4.Dispatch Semaphore的使用
    static func dispatchSemaphore() -> Void {
        let queueGroup = DispatchGroup.init()
        let testSemaphore = DispatchSemaphore.init(value: 10)
        let globalQueue = DispatchQueue.global()
        
        for i in 0 ..< 50 {
            testSemaphore.wait()
            globalQueue.async(group: queueGroup, execute: DispatchWorkItem.init(block: {
                printWithMessage("这是第\(i)个")
                sleep(3)
                testSemaphore.signal()
            }))
        }
        
    }
    
    
    /// 获取本地语言
    static func getCurrentLanguage() -> String {
        
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "cn"//中文
        default:
            return "en"
        }
    }
    
    
    /// 获取屏幕宽
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// 获取屏幕高
    static func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    /// 获取本机型号
    static func getIPhoneType() ->String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        
        if platform == "iPhone1,1" { return "iPhone 2G"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,6" { return "iPhone X"}
        
        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
        return platform
    }
    
    /// JSON转字典
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try (((JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])))
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    
    /// 生成一个随机数(给定范围)
    static func randomInRange(range: CountableClosedRange<Int>) -> Int {
        let countUInt32 = UInt32(range.upperBound - range.lowerBound)
        return Int(arc4random_uniform(countUInt32)) + range.lowerBound
    }
    
    
    /// 生成一个随机字符串 [位数] -> String
    static func createRandomString(_ bitCount: Int) -> String {
        
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var ranStr = ""
        for _ in 0 ..< bitCount {
            let index = Int(arc4random_uniform(UInt32(characters.characters.count)))
            ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }// funcEnd
    
    
    
    
    ///  线程锁
    static func synchronizedLock(needLockObject:AnyObject, closure:()->()) -> Void{
        objc_sync_enter(needLockObject)
        closure()
        objc_sync_exit(needLockObject)
    }
    
    /// 动画类
    static func baseAnimationWithKeyPath(_ path : String , fromValue : Any? , toValue : Any?, duration : CFTimeInterval, repeatCount : Float? , timingFunction : String?) -> CABasicAnimation{
        
        let animate = CABasicAnimation(keyPath: path)
        //起始值
        animate.fromValue = fromValue;
        
        //变成什么，或者说到哪个值
        animate.toValue = toValue
        
        //所改变属性的起始改变量 比如旋转360°，如果该值设置成为0.5 那么动画就从180°开始
        //        animate.byValue =
        
        //动画结束是否停留在动画结束的位置
        animate.isRemovedOnCompletion = true
        
        //动画时长
        animate.duration = duration
        
        //重复次数 Float.infinity 一直重复 OC：HUGE_VALF
        animate.repeatCount = repeatCount ?? 0
        
        //设置动画在该时间内重复
        //        animate.repeatDuration = 5
        
        //延时动画开始时间，使用CACurrentMediaTime() + 秒(s)
        //        animate.beginTime = CACurrentMediaTime() + 2;
        
        //设置动画的速度变化
        /*
         kCAMediaTimingFunctionLinear: String        匀速
         kCAMediaTimingFunctionEaseIn: String        先慢后快
         kCAMediaTimingFunctionEaseOut: String       先快后慢
         kCAMediaTimingFunctionEaseInEaseOut: String 两头慢，中间快
         kCAMediaTimingFunctionDefault: String       默认效果和上面一个效果极为类似，不易区分
         */
        
        if timingFunction == nil {
            animate.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
            
        }else {
            animate.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.init(rawValue: timingFunction!))
            
        }
        
        
        
        
        
        //动画在开始和结束的时候的动作
        /*
         kCAFillModeForwards    保持在最后一帧，如果想保持在最后一帧，那么isRemovedOnCompletion应该设置为false
         kCAFillModeBackwards   将会立即执行第一帧，无论是否设置了beginTime属性
         kCAFillModeBoth        该值是上面两者的组合状态
         kCAFillModeRemoved     默认状态，会恢复原状
         */
        animate.fillMode = CAMediaTimingFillMode.both
        
        //动画结束时，是否执行逆向动画
        //        animate.autoreverses = true
        
        return animate
        
    }
    
    
    //MARK: - 获取IP
    static func getIPAddresses() -> String? {
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }

}

// MARK: - 线程类;
/// 延时执行类
public class DelayTask: NSObject {
    
    /// 任务字典
    static var workItemDict: Dictionary<String, DispatchWorkItem> = Dictionary<String, DispatchWorkItem>.init()
    
    /// 任务数组
    static var workTimerArray: [Timer] = []

    /// 创建一个延时执行任务并加入任务字典
    static func createTaskWith(workItem: (() -> ())?, delayTime: TimeInterval) -> Void {
        
        let workTimer = Timer.scheduledTimer(
                            withTimeInterval: delayTime,
                            repeats: false) { (timer) in
                                if workItem != nil {
                                    workItem!()
                                }
                        }
        
        self.workTimerArray.append(workTimer)
        
    }// funcEnd
    
    static func cancelAllWorkItems() -> Void {
        for workTimer in workTimerArray {
            workTimer.invalidate()
        }

        self.workTimerArray = []
    }// funcEnd
    
}

/// 打印对象及信息
public func printWithMessage<T>(_ printObj: T,
                                file: String = #file,
                                method: String = #function,
                                line: Int = #line) -> Void {
    #if DEBUG
    let fileString: String = file as String
    let index = fileString.range(of: "/", options: .backwards, range: nil, locale: nil)?.upperBound
    let newStr = fileString[index!...]
    print("打印信息汇总:{\n  所属文件:\(newStr)\n  该方法名:\(method)\n  所在行数:\(line)\n  对象内容:\(printObj)\n}")
    #endif
}

public func shuffle(toShuffle: [Int]) -> [Int] {
    var list = toShuffle
    for index in 0..<list.count {
        let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
        if index != newIndex {
            list.swapAt(index, newIndex)
        }
    }
    return list
}



