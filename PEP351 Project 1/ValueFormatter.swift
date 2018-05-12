//
//  ValueFormatter.swift
//  PEP351 Project 1
//
//  Created by Zachary Shakked on 4/6/17.
//  Copyright © 2017 Shakd, LLC. All rights reserved.
//

import UIKit
import Charts

public final class ValueFormatter: NSObject, IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .scientific
        let number = NSNumber(value: value)
        
        return numberFormatter.string(from: number) ?? ""
    }
    
}
