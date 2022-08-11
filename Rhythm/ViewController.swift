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

@available(iOS 14.0, *)
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
    
    var dyView = UIView()
    
    var dataSource = [NSMutableArray]()
    var dyDataSource = [RhythmDyModel]()
    
    var index:Int = 0
    
    var square:UIView!
    var duration:CFTimeInterval = 1
    var pathLayer:CAShapeLayer!
    
    var selectRhythmModel: RhythmModel!

    //https://sc.chinaz.com/yinxiao/index_23.html
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        initData()
        initUI()
        
        startTimer()
    }

    func initData() -> Void {
        
        for _ in 0..<32 {
            let model = RhythmDyModel()
            model.viewSelect = false
            dyDataSource.append(model)
        }
        
        for _ in 0..<2 {
            let data = NSMutableArray()
            for _ in 0..<16 {
                let model = RhythmModel()
                model.color = kRandomColor()
                model.select = false
                
                //存空dymodel
//                for _ in 0..<32 {
//                    let dymodel = RhythmDyModel()
//                    dymodel.viewSelect = false
//                    model.dyModels.append(dymodel)
//                }
                //深拷贝
                model.dyModels = dyDataSource.map({$0.copy() as! RhythmDyModel})
                
                data.add(model)
            }
            dataSource.append(data)
        }
    }
    
    func initUI() -> Void {
        collection.delegate = self
        collection.dataSource = self
        dyCollection.delegate = self
        dyCollection.dataSource = self
        
        self.view.addSubview(collection)
        self.view.addSubview(dyCollection)
        
        let view = UIView.init(frame: CGRect(x: 10, y: 200, width: dyItemW, height: dyItemH))
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 4
        self.view.addSubview(view)
        self.dyView = view
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
                 
                 //闪动view
                 self.dyView.frame = CGRect(x: 10  + (dyItemW + collectMargin) * Double(self.index % 8), y: 200 + (dyItemH + collectMargin) * Double(self.index / 8), width: dyItemW, height: dyItemH)
                 //播放音频
                 self.playVideo(index: self.index)
             }
         })
         // 启动时间源
         timer.resume()
    }
    
    func playVideo(index:Int) -> Void {
        //查看闪动的index对应的dycell是否被选中
//        let dyModel = self.dyDataSource[index]
//
//        if dyModel.viewSelect && self.selectRhythmModel != nil {
//            self.playRhythmData(index: self.selectRhythmModel.playerIndex!)
//        }
        for arr in dataSource {
            for item in arr {
                let model = item as! RhythmModel
                for (i,dyModel) in model.dyModels.enumerated() {
                    if dyModel.viewSelect && i == index {
                        self.playRhythmData(index: model.playerIndex!)
                    }
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
            self.view.layer.addSublayer(playLayer)
            play.play()
        }
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
        
        cell.dyModel = dyDataSource[indexPath.row]
        
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
            
            //内存地址打印
//            for (_,item) in rhythmModel!.dyModels.enumerated() {
//                print(String.init(format: "%p", item))
//            }
            
            rhythmModel?.select = true
            rhythmModel?.playerIndex = indexPath.section * 16 + indexPath.row
            selectRhythmModel = rhythmModel
            dyDataSource = selectRhythmModel.dyModels
            
            //播放
            playRhythmData(index: selectRhythmModel!.playerIndex!)
            
            collection.reloadData()
            dyCollection.reloadData()
        }
        else {
            
            if selectRhythmModel == nil {
                return
            }
            
            let dyModel = self.dyDataSource[indexPath.row]
            dyModel.viewSelect = !dyModel.viewSelect
            dyModel.color = selectRhythmModel.color
            selectRhythmModel.dyModels[indexPath.row] = dyModel
            
            //刷新cell
            dyCollection.reloadItems(at: [indexPath])
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

