//
//  ViewController.swift
//  GraphIt
//
//  Created by Ömer Yetik on 28/09/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import UIKit

class GraphViewController: VCLLoggingViewController {

    // Public API
    
    // This is the model for Graphing MVC. It is simply an x-y function
    
    var functionToGraph: ((Double) -> Double)? {
        didSet {
            updateUI()
        }
    }
    
    var graphTitle: String?

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            print("GraphView didSet is called")
            graphView.contentMode = .redraw
            let pinchHandler = #selector(graphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            let panOrTapRecognizer = #selector(graphView.changeOrigin(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panOrTapRecognizer)
            graphView.addGestureRecognizer(panRecognizer)
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: panOrTapRecognizer)
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            updateUI()
        }
    }
    
    // Updating the UI corresponds to setting the function to be drawn
    private func updateUI() {
        if functionToGraph == nil {
            // If functionToGraph is nil, it means either it is not set, or is set to nil
            // In such a case look if there is any stored function from the last session
            // and set the function to the stored one if available
        } else {
            graphView?.functionToGraph = functionToGraph
        }
        navigationItem.title = graphTitle
    }
    
    
    // AÊCT2: Store scale and origin

    
    private func saveDefaults() {
        // No need to cast origin and scale as Any?. When getting the values,
        // they are already returned as Any?
        defaults.setCGPoint(graphView.origin, forKey: Keys.keyForOrigin)
        defaults.set(Float(graphView.scale), forKey: Keys.keyForScale)
//        if let graph = functionToGraph {
//            var graph = graph
//            let data = withUnsafePointer(to: &graph) {
//                Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: graph))
//            }
//            defaults.set(data, forKey: Keys.keyForFunction)
//            
//        }
    }
    
    private var defaultOrigin: CGPoint {
        if let defaultOrigin = defaults.cgPoint(forKey: Keys.keyForOrigin) {
            return defaultOrigin
        } else {
            return CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
        }
    }
    
    private var defaultScale: CGFloat {
        let defaultScale = defaults.float(forKey: Keys.keyForScale)
        if defaultScale != 0 {
            return CGFloat(defaultScale)
        } else {
            return graphView.scale
        }
    }
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        graphView.origin = defaultOrigin
        graphView.scale = defaultScale
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDefaults()
    }
    
    
    
}

