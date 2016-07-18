//
//  NextViewController.swift
//  ConvertUIViewToUIImageTest
//
//  Created by ImaedaToshiharu on 2016/07/08.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    @IBOutlet weak var myImgView: UIImageView!
    var image:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.myImgView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapSaveToCamRoll(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, #selector(NextViewController.alertCompOfSaving(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func alertCompOfSaving(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        
        let title:String = ""
        var message:String = "アルバムへの保存が完了しました"
        
        if error != nil {
            message = "アルバムへの保存に失敗しました"
        }
        
        let alc:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok:UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alc.addAction(ok)
        self.presentViewController(alc, animated: true, completion: nil)
    }
    
    @IBAction func onTapBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
