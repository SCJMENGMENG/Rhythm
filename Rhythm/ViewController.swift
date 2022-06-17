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
import SnapKit

let kW:Double = Double(UIScreen.main.bounds.width)
let kH:Double = Double(UIScreen.main.bounds.height)

func kRandomColor() -> UIColor {
    return UIColor.init(red: CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 256.0, green: CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 256.0, blue: CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 256.0, alpha: 1.0)
}

let itemW = 40.0
let collectMargin = 10.0
let space = 5.0

let dyItemW = (kW - 90) / 8.0
let dyItemH = (kW - 90) / 8.0 + 20

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = UICollectionView.init(frame: CGRect(x: collectMargin, y: kH - 300, width: kW - 2*collectMargin, height: itemW * 4 + space * 3), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.cyan
        collection.layer.cornerRadius = 5
        collection.register(RhythmCell.self, forCellWithReuseIdentifier: "RhythmCell")
        
        layout.itemSize = CGSize(width: itemW, height: itemW)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        return collection
    }()
    
    var dyCollection: UICollectionView = {
        let dyLayout = UICollectionViewFlowLayout.init()
        let dyCollection = UICollectionView(frame: CGRect(x: 0, y: 200, width: kW, height: (dyItemH * 4 + collectMargin * 3)), collectionViewLayout: dyLayout)
        dyCollection.register(RhythmDyCell.self, forCellWithReuseIdentifier: "RhythmDyCell")
        
        dyLayout.itemSize = CGSize(width: dyItemW, height: dyItemH)
        dyLayout.minimumLineSpacing = collectMargin
        dyLayout.minimumInteritemSpacing = collectMargin
        dyLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return dyCollection
    }()
    
    var dataSource = [NSMutableArray]()
    var dyDataSource = [RhythmDyModel]()
    
    var index = 0
    var selectPath:IndexPath?

    //https://sc.chinaz.com/yinxiao/index_23.html
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        initData()
        initUI()
    }

    func initData() -> Void {
        for _ in 0..<2 {
            let data = NSMutableArray()
            for _ in 0..<16 {
                let model = RhythmModel()
                model.color = kRandomColor()
                model.select = false
                data.add(model)
            }
            dataSource.append(data)
        }
        
        for i in 0..<32 {
            let model = RhythmDyModel()
            model.flash = i == 0
            dyDataSource.append(model)
        }
    }
    
    func initUI() -> Void {
        collection.delegate = self
        collection.dataSource = self
        dyCollection.delegate = self
        dyCollection.dataSource = self
        
        self.view.addSubview(collection)
        self.view.addSubview(dyCollection)
        
        startTimer()
    }
    
    //播放音频资源
    func playRhythmData(index:Int) -> Void {
        let audioPath = Bundle.main.path(forResource: "bg_\(index)", ofType: "mp3")
        if let filePath = audioPath {
            let url = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem.init(url: url)
            let play = AVPlayer.init(playerItem: playerItem)
            let playLayer = AVPlayerLayer.init(player: play)
            self.view.layer.addSublayer(playLayer)
            play.play()
        }
    }
    
    //计时轮播
    func startTimer() {
         // 定义需要计时的时间
         var timeCount = 32
         // 在global线程里创建一个时间源
         let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
         // 设定这个时间源是每秒循环一次，立即开始
        timer.schedule(deadline: .now(), repeating: 0.3)        // 设定时间源的触发事件
         timer.setEventHandler(handler: {
             let indexPathBefore:IndexPath!
             let indexPath = IndexPath(row: self.index, section: 0)
             if self.index > 0 {
                 let model:RhythmDyModel = self.dyDataSource[self.index - 1]
                 model.flash = false
                 indexPathBefore = IndexPath(row: self.index - 1, section: 0)
             }
             else {
                 let model:RhythmDyModel = self.dyDataSource[31]
                 model.flash = false
                 indexPathBefore = IndexPath(row: 31, section: 0)
             }
             let model:RhythmDyModel = self.dyDataSource[self.index]
             model.flash = true
             
             self.index += 1
             
             // 每秒计时一次
             timeCount = timeCount - 1
             
             if self.index == 32 {
                 timeCount = 32
                 self.index = 0
             }
             // 时间到了取消时间源
             if timeCount <= 0 {
                 timer.cancel()
             }
             
             // 返回主线程处理一些事件，更新UI等等
             DispatchQueue.main.async {
                 print("-------%d",timeCount);
//                 self.dyCollection.reloadItems(at: [indexPathBefore,indexPath])
                 self.dyCollection.reloadData()
             }
         })
         // 启动时间源
         timer.resume()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == collection {
            return dataSource.count
        }
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            let dataSource = dataSource[section]
            return dataSource.count
        }
        return self.dyDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RhythmCell", for: indexPath) as! RhythmCell
            let data = dataSource[indexPath.section]
            cell.rhythmModel = data[indexPath.row] as? RhythmModel
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RhythmDyCell", for: indexPath) as! RhythmDyCell
        cell.backgroundColor = CGFloat(indexPath.row).truncatingRemainder(dividingBy: 2) > 0 ? UIColor.green : UIColor.purple
        cell.rhythmDyModel = dyDataSource[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collection {
            //取消collection cell选中
            let data = dataSource[indexPath.section]
            for item in dataSource {
                for model in item {
                    let rhythmModel = model as! RhythmModel
                    rhythmModel.select = false
                }
            }
            
            //播放collection cell
            let rhythmModel = data[indexPath.row] as? RhythmModel
            rhythmModel?.select = true
            rhythmModel?.playerIndex = indexPath.section * 16 + indexPath.row
            playRhythmData(index: indexPath.section * 16 + indexPath.row)
            collection.reloadData()
            dyCollection.reloadData()
            
            selectPath = indexPath
        }
        else {
            print("-------row:%d",indexPath.row);
            let dyModel = self.dyDataSource[indexPath.row]
            if selectPath != nil {
                let data = dataSource[selectPath!.section]
                let rhythmModel = data[selectPath!.row] as? RhythmModel
                let contains: Bool = dyModel.rhythmArr.contains { model in
                    return model == rhythmModel
                }
                if contains {
                    let newDyModel = dyModel.rhythmArr.filter { (item) -> Bool in
                        return item != rhythmModel
                    }
                    dyModel.rhythmArr = newDyModel
                }
                else {
                    dyModel.rhythmArr.append(rhythmModel!)
                }
            }
            dyCollection.reloadItems(at: [indexPath])
//            dyCollection.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if collectionView == collection {
            let hW = Double(kW - 8 * itemW - 2 * collectMargin - 6 * space)
            return section == 0 ? CGSize(width: hW, height: 0) : CGSize(width: 0, height: 0)
        }
        return CGSize(width: 0, height: 0)
    }
}

