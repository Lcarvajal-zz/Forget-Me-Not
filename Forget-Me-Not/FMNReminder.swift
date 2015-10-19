//
//  FMNReminder.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 10/18/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit

class FMNReminder: NSObject {
    var title = NSString()
    var type = NSString()
    var completed = Bool()
    
    init(title: NSString, type: NSString, completed: Bool){
        self.title  = title
        self.type = type
        self.completed = completed
    }
}
