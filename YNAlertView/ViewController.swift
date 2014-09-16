//
//  ViewController.swift
//  YNAlertView
//
//  Created by Tommy on 14/9/15.
//  Copyright (c) 2014年 xu_yunan@163.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSystemAlert(sender: AnyObject) {
        let alertView = UIAlertView()
        alertView.title = "网络错误"
        alertView.message = "未能连接服务器"
        alertView.addButtonWithTitle("取消")
        alertView.addButtonWithTitle("确定")
        alertView.show()
    }

    @IBAction func showCustomAlert(sender: AnyObject) {
        let alertView = YNAlertView(title: "网络错误", message: "未能连接服务器")
        alertView.addButton("取消") {
            println("取消...")
        }
        alertView.addButton("确定") {
            println("确定...")
        }
        alertView.show()
    }

}

