//
//  GraphView.swift
//  GraphIt
//
//  Created by Ömer Yetik on 28/09/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    // Public API
    
    // Function that the GraphView draws
    var functionToGraph: ((Double) -> Double)? { didSet { setNeedsDisplay() } }
    
    // scale identifies points per unit in the view
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    
    // origin for graph
    @IBInspectable
    var origin: CGPoint = CGPoint.zero { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    
    var maxAllowedSwingScale: CGFloat = 0.5
    var minSwingToCheckForDiscontinuity: CGFloat = 10
    
    private var axesDrawer = AxesDrawer()
    
    // MARK: Gesture handling functions
    
    // Pinch Gesture handler : Modifies scale
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1.0 // reset scale of the gesture to allow incremental scaling
        default:
            break
        }
    }
    
    // Pan Gesture handler : Moves origin by a pan gesture
    // Tap Gesture Handler : Sets origin to the point tapped
    func changeOrigin(byReactingTo gestureRecognizer: UIGestureRecognizer) {
        if let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            switch panRecognizer.state {
            case .changed, .ended:
                let translation = panRecognizer.translation(in: self)
                origin.x += translation.x
                origin.y += translation.y
                panRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
            default:
                break
            }
        } else if let tapRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            switch tapRecognizer.state {
            case .recognized:
                let location = tapRecognizer.location(in: self)
                origin = location
            default:
                break
            }
        }
    }
    
    private func pointForFunction(correspondingTo xInViewCoordinates: CGFloat) -> (inViewCoordinates: CGPoint, inGraphCoordinates: CGPoint) {
        let xInGraphCoordinates = (-origin.x + xInViewCoordinates) / scale
        let yInGraphCoordinates: CGFloat
        // value assigned using the if let construct below to avoid crashing in live view on Storyboard
        if let function = functionToGraph {
            yInGraphCoordinates = CGFloat(function(Double(xInGraphCoordinates)))
        } else {
            yInGraphCoordinates = 0.0
        }
        let yInViewCoordinates = origin.y - (yInGraphCoordinates * scale)
        
        return (CGPoint(x: xInViewCoordinates, y: yInViewCoordinates),
                CGPoint(x: xInGraphCoordinates, y: yInGraphCoordinates))
    }
    
    private func drawGraph(in rect: CGRect) -> UIBezierPath {
        let numberOfPixelsOnXAxis = Int(rect.width * contentScaleFactor)
        let stepSizeInPoints = 1 / contentScaleFactor // one pixel = 1/contentScaleFactor points
        
        let graph = UIBezierPath()
        graph.lineWidth = lineWidth
        var lastPoint = pointForFunction(correspondingTo: 0)
        graph.move(to: lastPoint.inViewCoordinates)
        
        for pixelCount in 1...numberOfPixelsOnXAxis {
            
            let xInViewCoordinates = stepSizeInPoints * CGFloat(pixelCount)
            let nextPoint = pointForFunction(correspondingTo: xInViewCoordinates)
            
            // Ensure that y-Value for pixel is valid. Otherwise iterate to next pixel
            guard nextPoint.inGraphCoordinates.y.isNormal || nextPoint.inGraphCoordinates.y.isZero else {
                continue
            }
            
            // If the point is not in the visible rect, move to the next pixel.
            let pointIsNotVisible = !rect.contains(nextPoint.inViewCoordinates)
            
            // Check for discontinuity.
            // Occurs if there is a sign change in y-values between consecutive pixels AND
            // difference in y-values for consecutive pixels is larger than the y-value for next pixel
            var discontinuity: Bool {
                let signChange = lastPoint.inGraphCoordinates.y * nextPoint.inGraphCoordinates.y < 0.0 ? true : false
                let swing = abs(lastPoint.inGraphCoordinates.y - nextPoint.inGraphCoordinates.y)
                // Check if swing is larger than 1 to avoid false discontinuities around y = 0.
                guard swing > minSwingToCheckForDiscontinuity else { return false }
                if swing > maxAllowedSwingScale * abs(nextPoint.inGraphCoordinates.y) && signChange {
                    return true
                }
                return false
            }

            // If discontinuity occurs move to the next point without drawing a line.
            // Otherwise draw the line.
            if discontinuity || pointIsNotVisible {
                graph.move(to: nextPoint.inViewCoordinates)
            } else {
                graph.addLine(to: nextPoint.inViewCoordinates)
            }
            
            lastPoint = nextPoint
        }

        return graph
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let graph = drawGraph(in: rect)
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale)
        UIColor.red.set()
        graph.stroke()
    }

}
