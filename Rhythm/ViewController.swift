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

/**
 //定义方式一
 var array1 = [[Int]]()
  
 //定义方式二
 var array2 = Array<Array<Int>>()
  
 array1 = [
   [13,1,4],
   [5,1,7,6]
 ]
  
 array2 = array1
  
 //　一维数组的定义
 var v = [Int]()
 v = [4,5,7,8]
 array2.append(v)
  
  
 println(array1)
 println(array2)
  
 //数组的遍历
 for var i=0; i<array1.count; i++ {
   for var j=0; j<array1[i].count; j++ {
     println(array1[i][j])
   }
 }
 */

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
    var filePathsArr = [NSMutableArray]()
//    var filePathsArr = Array<Array<Int>>()
    
    var index:Int = 0
    
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
        selectRhythmModel = RhythmModel()
        selectRhythmModel.play = AVPlayer.init()
        let selectPlayLayer = AVPlayerLayer.init(layer: selectRhythmModel.play as Any)
        self.view.layer.addSublayer(selectPlayLayer)
        
        for _ in 0..<32 {
            let model = RhythmDyModel()
            model.viewSelect = false
            
            model.play = AVPlayer.init()
            let playLayer = AVPlayerLayer.init(layer: model.play as AVPlayer)
            self.view.layer.addSublayer(playLayer)
            
            dyDataSource.append(model)
            filePathsArr.append(NSMutableArray.init())
//            filePathsArr.append([])
        }
        
        for _ in 0..<2 {
            let data = NSMutableArray()
            for _ in 0..<16 {
                let model = RhythmModel()
                model.color = kRandomColor()
                model.select = false
                
                //深拷贝 否则32个dyModels指向同一个地址
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
    
    //播放所有该cell打上的video
    func playVideo(index:Int) -> Void {
        
        let dyModel = self.dyDataSource[index];
        if (dyModel.filePath == nil) {
            return
        }
        let playerItem = AVPlayerItem.init(url: URL(fileURLWithPath: dyModel.filePath!))
        dyModel.play = AVPlayer.init(playerItem: playerItem)
        dyModel.play.play()
    }
    
    //播放音频资源
    func playRhythmData() -> Void {
        let index = selectRhythmModel!.playerIndex!
        let audioPath = Bundle.main.path(forResource: "bg_\(index)", ofType: "mp3")
        if let filePath = audioPath {
            let url = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem.init(url: url)
            selectRhythmModel.play = AVPlayer.init(playerItem: playerItem)
            selectRhythmModel.play.play()
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
        
        let dyModel = dyDataSource[indexPath.row]
        cell.dyModel = dyModel
        
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
            
            //先将32个数组里资源数组赋值给model里32个dyModel的数组
            for (index,item) in rhythmModel!.dyModels.enumerated() {
                item.filePaths = filePathsArr[index] as! [Int]
//                item.filePaths = filePathsArr[index]
            }
            
            dyDataSource = rhythmModel!.dyModels
            
            //播放
            playRhythmData()
            
            collection.reloadData()
            dyCollection.reloadData()
            print("---scj--cell:\(selectRhythmModel.playerIndex!)")
        }
        else {
            
            if selectRhythmModel == nil {
                return
            }
            
            let dyModel = self.dyDataSource[indexPath.row]
            dyModel.viewSelect = !dyModel.viewSelect
            dyModel.color = selectRhythmModel.color
            
            var filePaths = self.filePathsArr[indexPath.row]
            
            //有就先移除
            for (index,item) in filePaths.enumerated() {
                if (item as! Int == selectRhythmModel.playerIndex!) {
                    filePaths.remove(item)
//                    filePaths.remove(at: index)
                    break
                }
            }
            
            //增加选中的video
            if dyModel.viewSelect {
                print("---scj--playerIndex:\(selectRhythmModel.playerIndex!)")
                filePaths.add(selectRhythmModel.playerIndex!)
//                filePaths.append(selectRhythmModel.playerIndex!)
            }
            
            dyModel.filePaths = filePaths as! [Int]
            
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

