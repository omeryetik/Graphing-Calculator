//
//  ViewController.swift
//  GraphIt
//
//  Created by Ömer Yetik on 28/09/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    // Public API
    
    var dataSource: GraphViewDataSource?
    
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
            graphView.dataSource = self.dataSource
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = dataSource?.titleForGraph
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

