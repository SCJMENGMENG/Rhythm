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
    
    /*
     syntax = "proto3";

     message RWMobStatPublicParams {
       string deviceId = 1; // 设备号，除非用户卸载APP，否则取值不应变化
       string adId = 2; // 推广id（渠道）
       string appVer = 3; // 版本号
       string osType = 4; // 03官网;05编辑器；08安卓；09ios；
       string osVer = 5; // 操作系统版本号如ios11
       string deviceName = 6; // 设备名字
       string uuid = 7; // 内部设备ID
       string imei = 8; // 序列号
       string oaid = 9; // 移动安全联盟 设备唯一标识
       string adsId = 10; // Google广告ID（ads'I'd，I为大写的i）
       string MAC2 = 11;
       string umengDeviceToken = 12; //umeng标识
       string argoId = 13; // IOS特有参数 方舟的匿名id
       string androidId = 14; //安卓
       string idfa = 15; //iOS设备唯一标识
     }

     message RWMobStatPrivateParams {
       string type = 1; // 埋点类型
       string userCode = 2; // userCode
       string openId = 3; // openId
       string flag = 4; // 0是研发安卓 1是研发iOS 2是研发web端 3是平台安卓 4是平台iOS
       string os = 5; // 版本号
       string mac = 6;//mac 地址
       string lang = 7; //语言参数
       string token = 8; // token
       string unity_sdk_ver = 9;//"埋点上报时客户端状态：F（前台运行时埋点），B（后台运行时埋点）
       string selfUseCode = 10;//用户code
       string selfOpenid = 11;//用户外部ID
       string ts = 12;//发起请求时间戳
       string _sid = 13;//会话ID
       string mapId = 14;//游戏地图id，unity使用，android 当前为常量"0"
       map<string, string> event_attributes = 15; //ext01 ext02 拓展字段
     }
     */
    
    let kW:Double = Double(UIScreen.main.bounds.width)
    let kH:Double = Double(UIScreen.main.bounds.height)
    
    let itemW = 40.0
    let collectMargin = 10.0
    let space = 5.0

    //https://sc.chinaz.com/yinxiao/index_23.html
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
        
        let layout = UICollectionViewFlowLayout.init()
        let collection = UICollectionView.init(frame: CGRect(x: collectMargin, y: kH - 500, width: kW - 2*collectMargin, height: itemW * 4 + space * 3), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.cyan
        collection.delegate = self
        collection.dataSource = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        layout.itemSize = CGSize(width: itemW, height: itemW)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let hW = Double(kW - 8 * itemW - 2 * collectMargin - 6 * space)
        return section == 0 ? CGSize(width: hW, height: 0) : CGSize(width: 0, height: 0)
    }
}

