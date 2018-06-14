//
//  ViewController.swift
//  SamplePush
//
//  Created by Ketaki Damale on 18/04/18.
//  Copyright © 2018 Ketaki Damale. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.getNotification()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getNotification() {
        if manager.isGranted{
            manager.getNotification { (data) in
                print(data)
                DispatchQueue.main.async {
                      guard let aps = data["aps"] as? [String: AnyHashable] else {
                        return
                    }
                    guard let alert = aps["alert"] as? String else {
                        return
                    }
                    self.showAlert(alert)
                }
            }
        }
    }
    func showAlert (_ message:String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

