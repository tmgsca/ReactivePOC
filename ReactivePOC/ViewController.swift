//
//  ViewController.swift
//  ReactivePOC
//
//  Created by Thiago on 31/03/16.
//  Copyright © 2016 Thiago. All rights reserved.
//

import ReactiveCocoa
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        startTextFieldListener()
    }
    
    private func startTextFieldListener() {
        
        validTextFieldSignal().subscribeNext { self.textField.enabled = $0 as! Bool }
        
        textField.rac_textSignal()
            .skip(1)
            .filter { return !(self.isValid($0 as! String) as! Bool) }
            .doNext { _ in self.textField.enabled = false }
            .map { return ($0 as! String) + "mapped" }
            .subscribeNext { self.doRequest($0 as! String) }
    }
    
    private func doRequest(query: String) {
        self.requestSignal()
            .then { return self.textField.rac_textSignal() }
            .throttle(1)
            .subscribeNext { _ in
                self.textField.text = nil
                self.textField.enabled = true
            }
    }
    
    private func requestSignal() -> RACSignal {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            subscriber.sendNext("1" as NSString)
            subscriber.sendCompleted()
            return nil
        })
    }

    private func validTextFieldSignal() -> RACSignal {
        return textField.rac_textSignal().map { return self.isValid($0 as! NSString)}
    }
    
    private func isValid(text: NSString) -> AnyObject! {
        return text.length < 3
    }
}

