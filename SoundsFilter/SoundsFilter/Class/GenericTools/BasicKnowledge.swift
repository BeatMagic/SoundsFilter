//
//  Basic BasicKnowledge.swift
//  InterviewAboutSwft
//
//  Created by RainYoung on 2018/5/5.
//  Copyright © 2018年 RainYoung. All rights reserved.
//

import UIKit

class BasicKnowledge: NSObject {
    
    // MARK: - 一. 小方法
    /// 1.0 比较两个元素的大小
    static func getMin <T: Comparable> (_ a: T, _ b: T) -> T {
        if a > b {
            return b
            
        }else{
            return a
            
        }
    }
    
    // MARK: - 二. Map相关
    /// 2.0 使用Map函数操作
    static func UseMap(_ numArray: Array<Int>) -> Array<String> {
        return numArray.map({ (num) -> String in
            return "\(num)"
            
        })
    }
    
    /// 2.1 使用filter函数筛选
    static func UseFilter(_ numArray: Array<Int>) -> Array<Int> {
        return numArray.filter({ (num) -> Bool in
            return num >= 5
            
        })
    }
    
    /// 2.2 使用reduce函数求和
    static func UseReduce(_ numArray: Array<Int>) -> Int {
        
        // 0是起点
        return numArray.reduce(0, { (num1, num2) -> Int in
            return num1 + num2
        })
    }
    
    /// 2.3 使用reduce函数插入
    static func UseReduceInsert(_ letters: String) -> Dictionary<Character, Int> {
        
        // 0是起点
        return letters.reduce(into: [:]) { counts, letter in
            return counts[letter] = counts[letter, default: 0] + 1
        }
    }
    
    /// 2.4 使用FlatMap将多层数组"脱壳"
    static func UseFlatMap(_ array: Array<Array<Int>>) -> Array<Int> {
        
        return array.flatMap({ (itemArray) -> Array<Int> in
            return itemArray
        })
        
    }
    
    /// 2.5 使用compactMap掉滤为nil的元素
    static func UseCompactMapTakeOutNil(_ array: Array<Any?>) -> Array<Any> {
        return array.compactMap({ (item) -> Any? in
            return item
        })
    }
    
    // MARK: - 三. 字符串相关
    /// 3.1 返回一个字符串的长度 ("吃饭" [2, 6])
    static func getStringLength(_ string: String) -> Array<Int> {
        return [string.count, string.lengthOfBytes(using: .utf8)]
    }
    

}
