//
//  ViewController.swift
//  ConvertUIViewToUIImageTest
//
//  Created by ImaedaToshiharu on 2016/07/07.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var targetView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "nextView") {
            let vc:NextViewController = (segue.destinationViewController as? NextViewController)!
            vc.image = self.getConvertedImg()
        }
    }
    
    func getConvertedImg() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.targetView.bounds.size, self.targetView.opaque, 0.0)
        let context:CGContext = UIGraphicsGetCurrentContext()!
//        CGContextTranslateCTM(context, -self.targetView.frame.origin.x, -self.targetView.frame.origin.y)      // 平行移動メソッド
        self.targetView.layer.renderInContext(context)
        let renderImg:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return renderImg
    }

    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        
        let partsView:UIView = sender.view!
        
        if sender.state == .Began {
            
            NSLog("【Start】ドラッグが始まりました")
            
            // レイヤーを一番上に持ってくる
            partsView.translatesAutoresizingMaskIntoConstraints = true
            self.targetView.bringSubviewToFront(partsView)
        }
        
        let point:CGPoint = sender.translationInView(self.targetView)
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: self.targetView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    

}

