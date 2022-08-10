//
//  RhythmDyModel.swift
//  Rhythm
//
//  Created by scj on 2022/6/14.
//

import Foundation
import UIKit

class RhythmDyModel: NSObject, NSCopying {
    
    var viewSelect: Bool!
    var color: UIColor!
    
    func copy(with zone: NSZone? = nil) -> Any {
        let dyModel = RhythmDyModel()
        dyModel.viewSelect = self.viewSelect
        dyModel.color = self.color
        return dyModel
    }
}
