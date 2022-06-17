//
//  RhythmDyCell.swift
//  Rhythm
//
//  Created by scj on 2022/6/14.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class RhythmDyCell: UICollectionViewCell {
    
    var centerView: UIView!
    
    var rhythmDyModel: RhythmDyModel! {
        didSet {
            self.layer.borderWidth = rhythmDyModel.flash ? 5 : 0
            self.layer.borderColor = rhythmDyModel.flash ? UIColor.white.cgColor : UIColor.clear.cgColor
            centerView?.isHidden = true
            centerView?.backgroundColor = UIColor.clear
            for model in rhythmDyModel.rhythmArr {
                //显示中间view颜色
                if model.select {
                    centerView.isHidden = false
                    centerView.backgroundColor = model.color
                }
                if rhythmDyModel.flash {
                    self.playRhythmData(index: model.playerIndex!)
                }
            }
        }
    }
    
    //播放音频资源
    func playRhythmData(index:Int) -> Void {
        let audioPath = Bundle.main.path(forResource: "bg_\(index)", ofType: "mp3")
        if let filePath = audioPath {
            let url = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem.init(url: url)
            let play = AVPlayer.init(playerItem: playerItem)
            let playLayer = AVPlayerLayer.init(player: play)
            self.layer.addSublayer(playLayer)
            play.play()
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
        centerView = UIView()
        centerView.isHidden = true
        self.addSubview(centerView)
        centerView?.snp.makeConstraints({ make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize.init(width: 10, height: 10))
        })
    }
}
