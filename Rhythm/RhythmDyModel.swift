//
//  RhythmDyModel.swift
//  Rhythm
//
//  Created by scj on 2022/6/14.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class RhythmDyModel: NSObject, NSCopying {
    
    var viewSelect: Bool!
    var color: UIColor!
    var play: AVPlayer!
    var rhythmPlayer = RhythmPlayer()
    var filePath : String?
//    var filePaths: [Int] = NSMutableArray() as! [Int] {
    var filePaths = [Int]() {
        didSet {
            if filePaths.count == 0 {
                self.filePath = nil
                return
            }
            print("---scj--filePaths:\(filePaths)")
            rhythmPlayer.preparePlay(filePaths)
            rhythmPlayer.exportPlayBlock = { (filePath) in
                self.filePath = filePath
            }
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let dyModel = RhythmDyModel()
        dyModel.viewSelect = self.viewSelect
        dyModel.color = self.color
        return dyModel
    }
}
