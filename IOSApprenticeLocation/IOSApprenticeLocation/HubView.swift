//
//  HubView.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/12/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> UIView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        return hudView
    }
}
