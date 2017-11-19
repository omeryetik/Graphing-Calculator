//
//  UserDefaultsExtension.swift
//  Graphing Calculator
//
//  Created by Ömer Yetik on 12/11/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import Foundation
import UIKit

let defaults = UserDefaults.standard

struct Keys {
    static let keyForOrigin = "Defaults.origin"
    static let keyForScale = "Defaults.scale"
    static let keyForGraphViewState = "Defaults.graphView.state"
    static let keyForCalculatorState = "Defaults.calculator.state"
}

extension UserDefaults {
    
    //    Save the last origin of the graph to UserDefaults.
    func setCGPoint(_ value: CGPoint, forKey defaultName: String) -> () {
        let pointArray = [value.x, value.y]
        self.set(pointArray, forKey: defaultName)
    }
    
    func cgPoint(forKey defaultName: String) -> CGPoint? {
        if let pointArray = self.array(forKey: defaultName) as? [CGFloat] {
            return CGPoint(x: pointArray[0], y: pointArray[1])
        }
        return nil
    }
    

}
