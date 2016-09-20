//
//  CTFPulsusFormStepViewController.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

struct CTFPulsusFormItemAnswerStruct {
    var identifier: protocol<NSCoding, NSCopying, NSObjectProtocol>
    var value: Int
}

//class CTFPulsusFormStepViewController: ORKStepViewController, UITableViewDataSource, UITableViewDelegate, ORKFormItemCellDelegate, ORKTableContainerViewDelegate {
class CTFPulsusFormStepViewController: ORKStepViewController, UITableViewDataSource, UITableViewDelegate, CTFFormItemCellDelegate {

//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: CTFBorderedButton!
    @IBOutlet weak var formItemTableView: UITableView!
    
    override convenience init(step: ORKStep?) {
        self.init(step: step, result: nil)
    }
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        
        let framework = NSBundle(forClass: CTFPulsusFormStepViewController.self)
        self.init(nibName: "CTFPulsusFormStepViewController", bundle: framework)
        self.step = step
        self.initializeResults(result)
        self.restorationIdentifier = step!.identifier
        self.restorationClass = CTFPulsusFormStepViewController.self
        
        print(self.step)
        print(self.step?.title)
        if let formStep = self.step as? CTFPulsusFormStep {
            formStep.formItems?.forEach { formItem in
                print(formItem)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        let nib = UINib(nibName: "CTFFormItemCell", bundle: nil)
        self.formItemTableView.registerNib(nib, forCellReuseIdentifier: "ctf_form_item_cell")
        self.formItemTableView.rowHeight = UITableViewAutomaticDimension
        self.formItemTableView.cellLayoutMarginsFollowReadableWidth = false
        self.formItemTableView.separatorInset = UIEdgeInsetsZero
        
        
        
    }
    
    private var formItems: [ORKFormItem]? {
        guard let formStep = self.step as? CTFPulsusFormStep,
            let formItems = formStep.formItems else {
                return nil
        }
        
        return formItems
    }
    
    func initializeResults(result: ORKResult?) {
        
        guard let stepResult = result as? ORKStepResult,
             let itemResults = stepResult.results,
            var _ = self.answerDictionary else {
                return
        }
        
        itemResults.forEach { itemResult in
            guard let scaleResult = itemResult as? ORKScaleQuestionResult,
                let scaleValue = scaleResult.scaleAnswer as? Int else {
                    return
            }
            
            self.answerDictionary![scaleResult.identifier] = scaleValue
        }
        
    }
    
    var answerDictionary: [String: Int]?
    
    //whenver step is set, initialize the answerArray
    override var step: ORKStep? {
        didSet {
            guard let step = step as? CTFPulsusFormStep
                else { return }
            
            self.answerDictionary = [String: Int]()
            
            step.formItems?.forEach { formItem in
                if let answerFormat = formItem.answerFormat as? ORKScaleAnswerFormat{
                    self.answerDictionary![formItem.identifier] = answerFormat.defaultValue
                }
                else {
                    self.answerDictionary![formItem.identifier] = Int.max
                }
            }
        }
    }
    
    override var result: ORKStepResult? {
        guard let parentResult = super.result
            else {
            return nil
        }
        
        guard let step = self.step as? CTFPulsusFormStep,
            let formItems = step.formItems,
            let answerDictionary = self.answerDictionary else {
                return parentResult
        }
        
        let now = parentResult.endDate
        
        let formItemResults:[ORKScaleQuestionResult] = formItems.map { formItem in
            
            let scaleResult = ORKScaleQuestionResult(identifier: formItem.identifier)
            scaleResult.scaleAnswer = answerDictionary[formItem.identifier]
            scaleResult.startDate = now
            scaleResult.endDate = now
            return scaleResult
        }
        
        parentResult.results = formItemResults
        
        return parentResult
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleTextView.text = self.step?.title
        let sizeThatFits = self.titleTextView.sizeThatFits(CGSizeMake(self.titleTextView.frame.size.width, CGFloat(MAXFLOAT)))
        
        self.titleTextViewHeight.constant = sizeThatFits.height
        self.nextButton.setTitle("Next", forState: .Normal)
        self.nextButton.configuredColor = self.view.tintColor
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.formItems?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ctf_form_item_cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 8)
        
        guard let pulsusCell = cell as? CTFFormItemCell,
            let formItem = self.formItems?[indexPath.row],
            let scaleAnswerFormat = formItem.answerFormat as? ORKScaleAnswerFormat else {
                return cell
        }
        
        print(formItem.text)
        pulsusCell.formItem = formItem
        pulsusCell.titleTextView.text = formItem.text
        pulsusCell.setValue(self.answerDictionary![formItem.identifier]!)
        
        pulsusCell.minTextLabel.text = scaleAnswerFormat.minimumValueDescription
        pulsusCell.maxTextLabel.text = scaleAnswerFormat.maximumValueDescription
        
        pulsusCell.delegate = self
        
        return pulsusCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    
    func formItemCellAnswerChanged(cell: CTFFormItemCell, answer: Int) {
        if let formItem = cell.formItem {
            self.answerDictionary![formItem.identifier] = answer
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        self.goForward()
    }
}
