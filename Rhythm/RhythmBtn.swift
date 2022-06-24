//
//  RhythmBtn.swift
//  Rhythm
//
//  Created by scj on 2022/6/24.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

@available(iOS 14.0, *)
class RhythmBtn: UIButton {
    
    var centerView: UIView!
    
    var rhythmModel: RhythmModel? {
        didSet {
            self.isSelected = false
            let contains: Bool = ((rhythmDyModel?.rhythmArr.contains { model in
                return rhythmModel == model
            }) != nil)
            if contains {
                let newDymodel = rhythmDyModel?.rhythmArr.filter { (item) -> Bool in
                    return item != rhythmModel
                }
                rhythmDyModel?.rhythmArr = newDymodel!
            }
            else {
                rhythmDyModel?.rhythmArr.append(rhythmModel!)
                self.select(true)
            }
        }
    }
    
    var rhythmDyModel: RhythmDyModel?
    
    func timeSelect() -> Void {
        for model in rhythmDyModel!.rhythmArr {
            //显示中间view颜色
            if rhythmDyModel!.flash {
                self.playRhythmData(index: model.playerIndex!)
            }
        }
    }
    
    override func sendActions(for controlEvents: UIControl.Event) {
        super.sendActions(for: controlEvents)
        for model in rhythmDyModel!.rhythmArr {
            //显示中间view颜色
            if rhythmDyModel!.flash {
                self.playRhythmData(index: model.playerIndex!)
            }
        }
    }
    
    func selectMethod() -> Void {
        self.isSelected = !self.isSelected
        centerView.isHidden = !self.isSelected
        centerView.backgroundColor = self.isSelected ? rhythmModel?.color : UIColor.clear
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func creatUI() {
        
        centerView = UIView()
        centerView.isHidden = true
        self.addSubview(centerView)
        centerView?.snp.makeConstraints({ make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize.init(width: 10, height: 10))
        })
    }
}
