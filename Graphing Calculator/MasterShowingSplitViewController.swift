//
//  MasterShowingSplitViewController.swift
//  Graphing Calculator
//
//  Created by Ömer Yetik on 18/11/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import UIKit

class MasterShowingSplitViewController: UISplitViewController,
                                        UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
    }

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return false
    }

}
