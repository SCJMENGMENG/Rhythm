//
//  RhythmCell.swift
//  Rhythm
//
//  Created by scj on 2022/6/14.
//

import Foundation
import UIKit

class RhythmCell: UICollectionViewCell {
    
    var rhythmModel: RhythmModel! {
        didSet {
            self.backgroundColor = rhythmModel.color
            self.layer.borderWidth = rhythmModel.select ? 5 : 0
            self.layer.borderColor = rhythmModel.select ? UIColor.white.cgColor : UIColor.clear.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    private func creatUI() {
        self.layer.cornerRadius = 5
    }
}
