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
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Default the origin of the graph to the center of the view. Can be adjusted by the user.
        graphView.origin = CGPoint(x: graphView.bounds.width / 2, y: graphView.bounds.height / 2)
    }
    
}

