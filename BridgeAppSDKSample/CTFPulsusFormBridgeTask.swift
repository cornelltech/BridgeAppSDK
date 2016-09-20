//
//  CTFPulsusFormBridgeTask.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/19/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK

class CTFPulsusFormStepTransformer: NSObject, SBAStepTransformer {
    
    //this needs to contain all the info necessary to render a step
    //in the case of the CTFPulsusFormStep, this includes:
    //  - identifier
    //  - title
    //  - ORKFormItems (or info to generate)
    //  - 
    
    var stepIdentifier: String!
    var stepTitle: String?
    var formItems: [ORKFormItem]?
    
    init(identifier: String, title: String?, formItems: [ORKFormItem]?) {
        super.init()
        self.stepIdentifier = identifier
        self.stepTitle = title
        self.formItems = formItems
    }
    
    func transformToStep(factory: SBASurveyFactory, isLastStep: Bool) -> ORKStep? {
        let formStep = CTFPulsusFormStep(identifier: self.stepIdentifier)
        formStep.title = self.stepTitle
        formStep.optional = false
        formStep.formItems = self.formItems
        
        return formStep
    }
}

class CTFPulsusFormBridgeTask: NSObject, SBABridgeTask {
    
    var _taskIdentifier: String!
    var _schemaIdentifier: String?
    var stepTransformer: SBAStepTransformer?
    
    static func formItemFromDictionary(dictionary: AnyObject?) -> ORKFormItem? {
        
        let itemIdentifier:String = (dictionary?["identifier"])! as! String
        let text: String? = dictionary?["text"] as? String
        
        let range: AnyObject? = dictionary?["range"]
        let minimumValue = range?["min"] as? Int ?? 0
        let maximumValue = range?["max"] as? Int ?? 10
        let defaultValue = range?["default"] as? Int ?? 5
        let stepValue = range?["step"] as? Int ?? 1
        let maximumValueDescription = range?["maxValueText"] as? String ?? "extremely"
        let minimumValueDescription = range?["minValueText"] as? String ??  "not at all"

        let scaleAnswerFormat = ORKAnswerFormat.scaleAnswerFormatWithMaximumValue(maximumValue, minimumValue: minimumValue, defaultValue: defaultValue, step: stepValue, vertical: false, maximumValueDescription: maximumValueDescription, minimumValueDescription: minimumValueDescription)
        
        return ORKFormItem(identifier: itemIdentifier, text: text, answerFormat: scaleAnswerFormat)
    }
    
    init(dictionaryRepresentation: NSDictionary) {
        print(dictionaryRepresentation)
        super.init()
        
        self._taskIdentifier = dictionaryRepresentation["taskIdentifier"] as! String
        self._schemaIdentifier = dictionaryRepresentation["schemaIdentifier"] as? String
        
        
        guard let dictionaryItems = (dictionaryRepresentation["items"] as? [AnyObject]) else {
                return
        }
        
        let formItems = dictionaryItems.flatMap(CTFPulsusFormBridgeTask.formItemFromDictionary)
        self.stepTransformer = CTFPulsusFormStepTransformer(identifier: self._taskIdentifier,
                                                            title: dictionaryRepresentation["title"] as? String,
                                                            formItems: formItems)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var taskIdentifier: String! {
        return self._taskIdentifier
    }
    
    var schemaIdentifier: String! {
        return self._schemaIdentifier
    }
    
    var taskSteps: [SBAStepTransformer] {
        return (self.stepTransformer != nil) ? [self.stepTransformer!] : []
    }
    
    var insertSteps: [SBAStepTransformer]? {
        return nil
    }
    
    
    
}
