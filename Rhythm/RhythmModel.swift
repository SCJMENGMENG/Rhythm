//
//  RhythmModel.swift
//  Rhythm
//
//  Created by scj on 2022/6/14.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class RhythmModel: NSObject {
    var select: Bool!
    var color: UIColor!
    var playerIndex: Int?
    var dyModels = [RhythmDyModel]()
    var play: AVPlayer!
}
