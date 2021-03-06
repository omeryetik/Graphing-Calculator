//
//  ViewController.swift
//  Graphing Calculator
//
//  Created by Ömer Yetik on 15/10/2017.
//  Copyright © 2017 Ömer Yetik. All rights reserved.
//

import UIKit

//  A1ECT2
var numberFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.minimumIntegerDigits = 1
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.negativeInfinitySymbol = "Error"
    formatter.positiveInfinitySymbol = "Error"
    return formatter
}   //

class CalculatorViewController: VCLLoggingViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var memory: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    
    var userIsInTheMiddleOfTyping = false
    var userDidUndoLastOperation = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //  A1RT1
            if !(textCurrentlyInDisplay.contains(".") && digit == ".") {
                display.text = textCurrentlyInDisplay + digit
            }  //
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = numberFormatter.string(from: NSNumber(value:newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping  || userDidUndoLastOperation {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userDidUndoLastOperation = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        updateResultAndUI()
    }
    
    //  Utility function to pile up tasks to be done for updating the
    //  Calculator VC (result, display, memory, history)
    func updateResultAndUI() {
        let evaluationResult = brain.evaluate(using: variables)
        
        if let result = evaluationResult.result {
            //  If result is not nil, update displayValue with result
            displayValue = result
            //  if update is being done due to an undoOperation and there is
            //  no a pending binary operation with a non-nil result, then the
            //  display is showing an operand for a unaryOperation or the first
            //  operand for a binary operation. So, revert back to "in the middle
            //  of typing" status to allow user to update the second operand on display
            if userDidUndoLastOperation && !evaluationResult.isPending {
                userIsInTheMiddleOfTyping = true
            }
        } else {
            //  if update is being done due to an undoOperation and there is
            //  a pending binary operation with result = nil, then the display is showing
            //  the second operand for a pending binary operation. Allow user to modify the operand
            if userDidUndoLastOperation && evaluationResult.isPending {
                userIsInTheMiddleOfTyping = true
            }
        }
        
        //  if update is being done due to an undo operation, no "=" should be shown in the
        //  display.
        if let errorMessage = evaluationResult.error {
            history.text = errorMessage
        } else {
            history.text = evaluationResult.description + (evaluationResult.isPending ? " ..." :
                !userDidUndoLastOperation ? " =" : "")
        }
        
        //  Reset the undo operation tracking variable in case it was set to true.
        //  Meaningful only if the update method was called due to an undo operation.
        userDidUndoLastOperation = false
        
        if evaluationResult.isPending || evaluationResult.result == nil {
            canGraph = false
        } else {
            canGraph = true
        }
        saveCalculatorState()
    }
    
    //  Corrsponds to →M button
    @IBAction func setVariable() {
        userIsInTheMiddleOfTyping = false
        variables["M"] = displayValue
        if let displayValueAsString = numberFormatter.string(from: NSNumber(value:displayValue)) {
            memory.text = "M = " + displayValueAsString
        }
        updateResultAndUI()
    }
    
    //  Corresponds to M button
    @IBAction func getVariable() {
        brain.setOperand(variable: "M")
        updateResultAndUI()
    }
    
    //  A1RT8
    @IBAction func clear() {
        brain.reset()
        displayValue = 0
        variables = [:]
        history.text = " "
        memory.text = " "
        userIsInTheMiddleOfTyping = false
        canGraph = false
    }   //
    
    //  A1ECT1
    func backspace() {
        if var textCurrentlyInDisplay = display.text {
            if textCurrentlyInDisplay.characters.count > 1 {
                textCurrentlyInDisplay.characters.removeLast()
                display.text = textCurrentlyInDisplay
            } else {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction func undo() {
        userDidUndoLastOperation = true
        if userIsInTheMiddleOfTyping {
            backspace()
        } else {
            brain.undo()
            updateResultAndUI()
        }
    }   //
    
    // MARK: GraphViewDataSource Protocol Methods
    func yValue(for xValue: Double) -> Double {
        let evaluationResult = brain.evaluate(using: ["M" : xValue])
        return evaluationResult.result ?? 0.0
    }
    
    var titleForGraph: String {
        return brain.evaluate(using: variables).description
    }

    // MARK: Graph function related variables
    
    // A3ECT1: If current operation cannot be graphed, decrease alpha of the graph button.
    var canGraph: Bool = false {
        willSet {
            if newValue != canGraph {
                graphButton.alpha = newValue == true ? 1.0 : 0.3
            }
        }
    }
    //
    
    // MARK: Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "graph" {
            return canGraph
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let graphViewController = destinationViewController as? GraphViewController {
            prepareGraphViewController(graphViewController)
            saveGraph()
        }
    }
    
    private func prepareGraphViewController(_ gvc: GraphViewController) {
        gvc.functionToGraph = { [weak weakSelf = self] in
            (weakSelf?.brain.evaluate(using: ["M" : $0]).result)!
        }
        gvc.graphTitle = "y = " + brain.evaluate(using: variables).description
        
    }
    
//    Save and Restore graphView and Calculator states
    
    private var isInASplitView: Bool {
        return splitViewController != nil
    }
    
    private func saveGraph() {
        defaults.set(brain.calculatorProgram, forKey: Keys.keyForGraphViewState)
    }
    
    private func restoreGraph() {
        if isInASplitView {
            if let navigationController = splitViewController!.viewControllers[1] as? UINavigationController,
                let graphViewController = navigationController.topViewController as? GraphViewController {
                if let program = defaults.array(forKey: Keys.keyForGraphViewState) {
                    brain.calculatorProgram = program
                    prepareGraphViewController(graphViewController)
                }
            }
        }
    }
    
    private func saveCalculatorState() {
        let propertiesToSave: [Any] = [brain.calculatorProgram, variables]
        defaults.set(propertiesToSave, forKey: Keys.keyForCalculatorState)
    }
    
    private func restoreCalculatorState() {
        if let properties = defaults.array(forKey: Keys.keyForCalculatorState) {
            brain.calculatorProgram = properties[0] as! [Any]
            variables = properties[1] as! Dictionary<String,Double>
            updateResultAndUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreGraph()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreCalculatorState()
    }

}



