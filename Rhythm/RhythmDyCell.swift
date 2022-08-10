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
    
    var cellBtn: UIButton!
    
    typealias btnBlock = () -> ()
    public var btnTestBlock: btnBlock?
    
    public var centerView: UIView!
    
    var dyModel: RhythmDyModel! {
        didSet {
            centerView.isHidden = !dyModel.viewSelect
            centerView.backgroundColor = dyModel.color != nil ? dyModel.color : UIColor.clear
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
    
    @objc func cellBtnClick() -> Void {
        
        btnTestBlock?()
        print("---btnClick")
    }
}
