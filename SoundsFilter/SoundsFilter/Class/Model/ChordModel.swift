//
//  ChordModel.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/19.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class ChordModel: NSObject {
    let chordName: String
    
    let chordNoteArray: [String]
    
    init(chordName: String, chordNoteArray: [String]) {
        self.chordName = chordName
        self.chordNoteArray = chordNoteArray
        
        super.init()
    }
}

class MajorUnknownChordModel: NSObject {
    let majorName: String
    
    let chord: [ChordModel]
    
    init(majorName: String, chord: [ChordModel]) {
        self.majorName = majorName
        self.chord = chord
        
        super.init()
    }
}

