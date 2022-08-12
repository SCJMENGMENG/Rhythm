//
//  RhythmPlayer.swift
//  Rhythm
//
//  Created by scj on 2022/8/11.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SnapKit

//https://blog.csdn.net/u011146511/article/details/79410222
class RhythmPlayer: UIView {
    
    var filePath: String?
    
    typealias exportBlock = (_ filePath: String) -> Void
    public var exportPlayBlock: exportBlock?
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer();
    
    public func preparePlay(_ data:[Int]) {
        
        //合成音频文件，第一步：创建AVMutableComposition
        let composition:AVMutableComposition = AVMutableComposition()
        
        for index in data {
            //本地音频文件的url
            let audioPath:String = Bundle.main.path(forResource: "bg_\(index)", ofType: "mp3")!
            let url = URL.init(fileURLWithPath: audioPath)

            //将源文件转换为可处理资源
            let originalAsset: AVURLAsset = AVURLAsset.init(url: url)

            //创建音频轨道素材
            let appendedAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

            //将再加工可用于拼接的音轨材料
            let assetTrack:AVAssetTrack = originalAsset.tracks(withMediaType: AVMediaType.audio).first!

            //控制时间范围
            let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: originalAsset.duration)

            //音频合并，插入音轨文件，音轨拼接
            try! appendedAudioTrack.insertTimeRange(timeRange, of: assetTrack, at: CMTime.zero)
        }
        
        //导出合并后的音频文件
        let exportSession: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        let filePath = self.createFilePath()
        print(filePath)
        
        exportSession.outputURL = URL(fileURLWithPath: filePath)
        exportSession.outputFileType = AVFileType.m4a
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            print("exportSession...",exportSession,exportSession.error as Any)
            switch exportSession.status {
            case.failed:
                print("failed")
                break
            case.completed:
                print("completed")
//                self.filePath = filePath
//                self.playVideo()
                
                self.exportPlayBlock?(filePath)
                break
            case.waiting:
                print("waiting")
                break
            default:break
            }
        })
    }
    
    func createFilePath() -> String {
        return NSTemporaryDirectory() + String(Date().timeIntervalSince1970) + ".mp4"
    }
    
    func playVideo() {
        if filePath == nil {
            print("---scj---filePath == nil")
            return
        }
        print(filePath!)
        
        //一：系统音频播放
//        var soundID : SystemSoundID = 0
//        AudioServicesCreateSystemSoundID(URL(fileURLWithPath: filePath!) as CFURL, &soundID)
//        AudioServicesPlayAlertSound(soundID)
//
//        AudioServicesPlayAlertSoundWithCompletion(soundID) {
//            print("音效文件播放完成")
//        }
        
        //二：AVAudioPlayer播放
        try! audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath!))
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        print("---")
    }
}

extension RhythmPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("播放完成")
        let userInfo = ["bkColor": "backgroundColor"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playFinish"), object: nil, userInfo: userInfo)
    }
}
