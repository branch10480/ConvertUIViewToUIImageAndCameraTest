//
//  CameraViewController.swift
//  ConvertUIViewToUIImageTest
//
//  Created by ImaedaToshiharu on 2016/07/08.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var captureMenuArea: UIView!
    
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    // 一時保存画像
    var tmpImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // セッションの作成.
        mySession = AVCaptureSession()
        
        // AVCaptureSessionPresetPhoto    写真専用、デバイスの最大解像度
        // AVCaptureSessionPresetHigh     最高録画品質 (静止画でも一番高画質なのはコレ)
        // AVCaptureSessionPresetMedium   WiFi向け
        // AVCaptureSessionPresetLow      3G向け
        // AVCaptureSessionPreset640x480  640x480 VGA固定
        // AVCaptureSessionPreset1280x720 1280x720 HD固定
        mySession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラからVideoInputを取得.
        let input:AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: self.myDevice)
        } catch {
            print("Caught Exception")
            return
        }
        
        // セッションに追加.
        mySession.addInput(input)
        
        // 出力先を生成.
        // AVキャプチャアウトプット (出力方法)
        myImageOutput = AVCaptureStillImageOutput()
        // AVCaptureStillImageOutput: 静止画
        // AVCaptureMovieFileOutput: 動画ファイル
        // AVCaptureAudioFileOutput: 音声ファイル
        // AVCaptureVideoDataOutput: 動画フレームデータ
        // AVCaptureAudioDataOutput: 音声データ
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.mySession)
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // 画面の向きを考慮
        if let orientation = self.convertUIOrientation2VideoOrientation({return self.appOrientation()}) {
            myVideoLayer.connection.videoOrientation = orientation
        }
        
        // Viewに追加.
        self.captureView.layer.addSublayer(myVideoLayer)
        // メニューを最前面に
        self.captureView.bringSubviewToFront(self.captureMenuArea)
        
        // セッション開始.
        mySession.startRunning()
    }
    
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.sharedApplication().statusBarOrientation
    }
    
    // UIInterfaceOrientation -> AVCaptureVideoOrientationにConvert
    func convertUIOrientation2VideoOrientation(f: () -> UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        let v = f()
        switch v {
        case UIInterfaceOrientation.Unknown:
            return nil
        default:
            return ([
                UIInterfaceOrientation.Portrait: AVCaptureVideoOrientation.Portrait,
                UIInterfaceOrientation.PortraitUpsideDown: AVCaptureVideoOrientation.PortraitUpsideDown,
                UIInterfaceOrientation.LandscapeLeft: AVCaptureVideoOrientation.LandscapeLeft,
                UIInterfaceOrientation.LandscapeRight: AVCaptureVideoOrientation.LandscapeRight
                ])[v]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapCaptureButton(sender: AnyObject) {
        
        // ビデオ出力に接続.
        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            // JpegからUIIMageを作成.
            var myImage : UIImage = UIImage(data: myImageData, scale: 1.0)!
            myImage = UIImage(CGImage: myImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Up)
            self.tmpImage = myImage
            
            // プレビューに表示
            self.previewImageView.image = myImage
            // プレビュー画面を表示
            self.previewView.alpha = 0
            self.view.bringSubviewToFront(self.previewView)
            UIView.animateWithDuration(0.2, animations: {() -> Void in
                self.previewView.alpha = 1
            })
        })
    }
    
    @IBAction func onTapUsePicButton(sender: AnyObject) {
        
        // アルバムに追加.
        UIImageWriteToSavedPhotosAlbum(self.tmpImage, self, #selector(CameraViewController.alertCompOfSaving(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func onTapRetakeButton(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: {() -> Void in
                self.previewView.alpha = 0
            }, completion: {(result) -> Void in
                self.view .sendSubviewToBack(self.previewView)
            })
    }
    
    @IBAction func onTapCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertCompOfSaving(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        
        let title:String = ""
        var message:String = "アルバムへの保存が完了しました"
        
        if error != nil {
            message = "アルバムへの保存に失敗しました"
        }
        
        let alc:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok:UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: {(result) -> Void in
        
            // 画面を閉じる
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alc.addAction(ok)
        self.presentViewController(alc, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
