//
//  Vector.swift
//  PEP351 Project 1
//
//  Created by Zachary Shakked on 4/5/17.
//  Copyright © 2017 Shakd, LLC. All rights reserved.
//

import UIKit
import Darwin

struct Vector: CustomStringConvertible {
    let x: Double
    let y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    var description: String {
        return "Vector(x: \(x), y: \(y), magnitude: \(magnitude))"
    }
    
    var magnitude: Double {
        return sqrt(x*x + y*y)
    }
    var unitVector: Vector {
        return Vector(x: x / magnitude, y: y / magnitude)
    }

    
    static func *(lhs: Double, rhs: Vector) -> Vector {
        return Vector(x: rhs.x * lhs, y: rhs.y * lhs)
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

}

