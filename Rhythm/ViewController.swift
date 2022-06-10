//
//  ViewController.swift
//  Rhythm
//
//  Created by scj on 2022/6/9.
//

import UIKit
import Foundation
import AVFoundation
import AVKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
    }

    func initUI() -> Void {
        
        for i in 0..<9 {
            
            let W = i%3
            let H = i/3
            
            let btn = UIButton.init(frame: CGRect.init(x: 30 + W * 120, y:100 + H * 120, width: 100, height: 100))
            btn.backgroundColor = UIColor.red
            btn.setTitle("i=\(i)", for: UIControl.State.normal)
            btn.addTarget(self, action: #selector(btnClick(button:)), for: UIControl.Event.touchUpInside)
            btn.tag = 100 + i
//            self.view.addSubview(btn)
        }
        let kW = UIScreen.main.bounds.width
        let kH = UIScreen.main.bounds.height
        
        let layout = UICollectionViewFlowLayout.init()
        let collection = UICollectionView.init(frame: CGRect(x: 10, y: kH - 500, width: kW - 20, height: 400), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.cyan
        collection.delegate = self
        collection.dataSource = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        self.view.addSubview(collection)
        
        
    }
    
    @objc func btnClick(button:UIButton) -> Void {
        print("btnClick")
        self.playVideo(tag:button.tag - 100)
    }

    func playVideo(tag:Int) -> Void {
        let audioPath = Bundle.main.path(forResource: "bg_\(tag)", ofType: "mp3")
//        if let url = URL(string: "http://img.youluwx.com/qa/20200917/video/c94869f4-0ddc-4e45-be7e-b0620acc544d.mp3") {
        if let filePath = audioPath {
            let url = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem.init(url: url)
            let play = AVPlayer.init(playerItem: playerItem)
            let playLayer = AVPlayerLayer.init(player: play)
//            playLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            self.view.layer.addSublayer(playLayer)
            
            play.play()
        }

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.green
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.playVideo(tag: indexPath.row)
    }
}

