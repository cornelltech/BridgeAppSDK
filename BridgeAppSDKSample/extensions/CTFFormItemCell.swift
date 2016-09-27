//
//  CTFFormItemCell.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/16/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

//- (void)formItemCell:(ORKFormItemCell *)cell answerDidChangeTo:(nullable id)answer;
//- (void)formItemCellDidBecomeFirstResponder:(ORKFormItemCell *)cell;
//- (void)formItemCellDidResignFirstResponder:(ORKFormItemCell *)cell;
//- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithMessage:(NSString *)input;
//- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message;
protocol CTFFormItemCellDelegate {
    func formItemCellAnswerChanged(cell: CTFFormItemCell, answer: Int)
}


class CTFFormItemCell: UITableViewCell {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var minTextLabel: UILabel!
    @IBOutlet weak var maxTextLabel: UILabel!
    @IBOutlet weak var topStackViewHeight: NSLayoutConstraint!
    
    var delegate: CTFFormItemCellDelegate?
    var answer: AnyObject? {
        didSet {
            if let answer = self.answer as? Int {
                self.setValue(answer)
            }
        }
    }
    
    var formItem: ORKFormItem?
    
    override func awakeFromNib() {
        self.valueSlider.minimumTrackTintColor = UIColor(red: 0.0021, green: 0.5427, blue: 0.8975, alpha: 1.0)
        self.valueSlider.maximumTrackTintColor = UIColor.grayColor()
        self.contentView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 8)
    }
    
    func configure(formItem: ORKFormItem, value: Int) {
        
        self.formItem = formItem
        self.titleTextView.text = formItem.text
        
        let textView = self.titleTextView
        let label = self.valueLabel
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        
        self.topStackViewHeight.constant = max(newSize.height, label.frame.size.height)
        
        
        self.setValue(value)
        
        if let scaleAnswerFormat = formItem.answerFormat as? ORKScaleAnswerFormat {
            self.minTextLabel.text = scaleAnswerFormat.minimumValueDescription
            self.maxTextLabel.text = scaleAnswerFormat.maximumValueDescription
        }
        
    }

    func setValue(value: Int) {
        self.valueSlider.setValue(Float(value), animated: true)
        self.updateValueLabel(value)
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        let sliderValue = self.valueSlider.value
        let intValue = lroundf(sliderValue)
        self.setValue(intValue)
        
        if let delegate = self.delegate {
            delegate.formItemCellAnswerChanged(self, answer: intValue)
        }
        
    }
    
    func updateValueLabel(value: Int) {
        self.valueLabel.text = "\(value)"
    }

}