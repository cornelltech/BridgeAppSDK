//
//  CTFScheduledActivityManager.swift
//  BridgeAppSDK
//
//  Created by James Kizer on 9/15/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

import UIKit
import BridgeAppSDK

//public protocol SBAScheduledActivityDataSource: class {
//    
//    func reloadData()
//    func numberOfSections() -> Int
//    func numberOfRowsInSection(section: Int) -> Int
//    func scheduledActivityAtIndexPath(indexPath: NSIndexPath) -> SBBScheduledActivity?
//    func shouldShowTaskForIndexPath(indexPath: NSIndexPath) -> Bool
//    
//    optional func didSelectRowAtIndexPath(indexPath: NSIndexPath)
//    optional func sectionTitle(section: Int) -> String?
//}

class CTFScheduledActivityManager: NSObject, SBASharedInfoController, ORKTaskViewControllerDelegate, SBAScheduledActivityDataSource, CTFScheduledActivityDataSource {
    weak var delegate: SBAScheduledActivityManagerDelegate?
    
    override init() {
        super.init()
    }
    
//    {
//    "scheduleType": "once",
//    "delay": "P3D",
//    "tasks": [
//    {
//    "taskTitle": "About You",
//    "taskID": "AboutYou-27829fa5-d731-4372-ba30-a5859f688297",
//    "taskFileName": "about_you",
//    "taskClassName": "APHDailyTaskViewController",
//    "taskCompletionTimeString": "8 Questions"
//    }
    
    
    init(delegate: SBAScheduledActivityManagerDelegate?, json: AnyObject) {
        super.init()
        self.delegate = delegate
        
        print(json)
        
        
        let activity1 = CTFActivity()
        activity1.label = "Memory"
        
        let scheduledActivity1 = CTFScheduledActivity()
        scheduledActivity1.activity = activity1
        scheduledActivity1.taskIdentifier = "Memory Activity"
        scheduledActivity1.guid = "12345678"
        
        let activity2 = CTFActivity()
        activity2.label = "PAM"
        
        let scheduledActivity2 = CTFScheduledActivity()
        scheduledActivity2.activity = activity2
        scheduledActivity2.taskIdentifier = "PAM"
        scheduledActivity2.guid = "12345678"
        
        let activity3 = CTFActivity()
        activity3.label = "Baseline"
        
        let scheduledActivity3 = CTFScheduledActivity()
        scheduledActivity3.activity = activity3
        scheduledActivity3.taskIdentifier = "Baseline"
        scheduledActivity3.guid = "12345678"
        
        
        self.activities = [scheduledActivity1, scheduledActivity2, scheduledActivity3]
    }
    
    lazy var sharedAppDelegate: SBAAppInfoDelegate = {
        return UIApplication.sharedApplication().delegate as! SBAAppInfoDelegate
    }()
    
    var bridgeInfo: SBABridgeInfo {
        return self.sharedBridgeInfo
    }
    
    var activities: [CTFScheduledActivity] = []
    
    func reloadData() {
        
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return self.activities.count
    }
    
    func scheduledActivityAtIndexPath(indexPath: NSIndexPath) -> SBBScheduledActivity? {
        return nil
    }
    
    func ctfScheduledActivityAtIndexPath(indexPath: NSIndexPath) -> CTFScheduledActivity? {
        return self.activities[indexPath.row]
    }
    
    func shouldShowTaskForIndexPath(indexPath: NSIndexPath) -> Bool {
//        guard let schedule = scheduledActivityAtIndexPath(indexPath) where shouldShowTaskForSchedule(schedule)
//            else {
//                return false
//        }
        return true
    }
    
//    func shouldShowTaskForSchedule(schedule: SBBScheduledActivity) -> Bool {
//        // Allow user to perform a task again as long as the task is not expired
//        guard let taskRef = bridgeInfo.taskReferenceForSchedule(schedule) else { return false }
//        return !schedule.isExpired && (!schedule.isCompleted || taskRef.allowMultipleRun)
//    }
    
    func scheduledActivityForTaskViewController(taskViewController: ORKTaskViewController) -> CTFScheduledActivity? {
        guard let vc = taskViewController as? SBATaskViewController,
            let guid = vc.scheduledActivityGUID
            else {
                return nil
        }
        return activities.findObject({ $0.guid == guid })
    }
    
    func scheduledActivityForTaskIdentifier(taskIdentifier: String) -> CTFScheduledActivity? {
        return activities.findObject({ $0.taskIdentifier == taskIdentifier })
    }
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
//        if reason == ORKTaskViewControllerFinishReason.Completed,
//            let schedule = scheduledActivityForTaskViewController(taskViewController)
//            where shouldRecordResult(schedule, taskViewController: taskViewController) {
//            
//             Update any data stores associated with this task
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: true)
//            
//             Archive the results
//            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
//            let archives = results.mapAndFilter({ archiveForActivityResult($0) })
//            SBADataArchive.encryptAndUploadArchives(archives)
//            
//             Update the schedule on the server
//            updateScheduledActivity(schedule, taskViewController: taskViewController)
//        }
//        else {
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: false)
//        }
        if reason == ORKTaskViewControllerFinishReason.Completed,
            let schedule = scheduledActivityForTaskViewController(taskViewController) {
            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
            print(results)
        }
        
        taskViewController.dismissViewControllerAnimated(true) {}
    }
    
    // Expose method for building results to allow for testing and subclass override
    func activityResultsForSchedule(schedule: CTFScheduledActivity, taskViewController: ORKTaskViewController) -> [SBAActivityResult] {
        
        // If no results, return empty array
        guard taskViewController.result.results != nil else { return [] }
        
        let taskResult = taskViewController.result
        let surveyTask = taskViewController.task as? SBASurveyTask
        
        // Look at the task result start/end date and assign the start/end date for the split result
        // based on whether or not the inputDate is greater/less than the comparison date. This way,
        // the split result will have a start date that is >= the overall task start date and an
        // end date that is <= the task end date.
        func outputDate(inputDate: NSDate?, comparison:NSComparisonResult) -> NSDate {
            let compareDate = (comparison == .OrderedAscending) ? taskResult.startDate : taskResult.endDate
            guard let date = inputDate where date.compare(compareDate) == comparison else {
                return compareDate
            }
            return date
        }
        
        // Function for creating each split result
        func createActivityResult(identifier: String, schedule: SBBScheduledActivity, stepResults: [ORKStepResult]) -> SBAActivityResult {
            let result = SBAActivityResult(taskIdentifier: identifier, taskRunUUID: taskResult.taskRunUUID, outputDirectory: taskResult.outputDirectory)
            result.results = stepResults
            result.schedule = schedule
            result.startDate = outputDate(stepResults.first?.startDate, comparison: .OrderedAscending)
            result.endDate = outputDate(stepResults.last?.endDate, comparison: .OrderedDescending)
            result.schemaRevision = surveyTask?.schemaRevision ?? bridgeInfo.schemaReferenceWithIdentifier(identifier)?.schemaRevision ?? 1
            return result
        }
        
        // mutable arrays for ensuring all results are collected
        var topLevelResults:[ORKStepResult] = taskViewController.result.consolidatedResults()
        var resultsForIdentifier: [String: ORKStepResult] = topLevelResults.reduce([String: ORKStepResult]()) { (acc, result) in
            var returnDictionary = acc
            returnDictionary[result.identifier] = result
            return returnDictionary
        }
        print(resultsForIdentifier)
        var allResults:[SBAActivityResult] = []
//        var dataStores:[SBATrackedDataStore] = []
        
        if let task = taskViewController.task as? SBANavigableOrderedTask {
            for step in task.steps {
                print(step)
                
                if let subtaskStep = step as? SBASubtaskStep {
                    print(subtaskStep)
//                    var isDataCollection = false
//                    if let subtask = subtaskStep.subtask as? SBANavigableOrderedTask,
//                        let dataCollection = subtask.conditionalRule as? SBATrackedDataObjectCollection {
//                        // But keep a pointer to the dataStore
//                        dataStores.append(dataCollection.dataStore)
//                        isDataCollection = true
//                    }
                    
                    if  let taskId = subtaskStep.taskIdentifier,
                        let schemaId = subtaskStep.schemaIdentifier {
                        
                        // If this is a subtask step with a schemaIdentifier and taskIdentifier
                        // then split out the result
                        let (subResults, filteredResults) = subtaskStep.filteredStepResults(topLevelResults)
                        topLevelResults = filteredResults
                        
                        // Add filtered results to each collection as appropriate
                        let subschedule: CTFScheduledActivity = scheduledActivityForTaskIdentifier(taskId) ?? schedule
//                        if subResults.count > 0 {
//                            
//                            // add dataStore results but only if this is not a data collection itself
//                            var subsetResults = subResults
//                            if !isDataCollection {
//                                for dataStore in dataStores {
//                                    if let momentInDayResult = dataStore.momentInDayResult {
//                                        // Mark the start/end date with the start timestamp of the first step
//                                        for stepResult in momentInDayResult {
//                                            stepResult.startDate = subsetResults.first!.startDate
//                                            stepResult.endDate = stepResult.startDate
//                                        }
//                                        // Add the results at the beginning
//                                        subsetResults = momentInDayResult + subsetResults
//                                    }
//                                }
//                            }
//                            
//                            // create the subresult and add to list
//                            let substepResult: SBAActivityResult = createActivityResult(schemaId, schedule: subschedule, stepResults: subsetResults)
//                            allResults.append(substepResult)
//                        }
                    }
//                    else if isDataCollection {
//                        
//                        // Otherwise, filter out the tracked object collection but do not create results
//                        // because this is tracked via the dataStore
//                        let (_, filteredResults) = subtaskStep.filteredStepResults(topLevelResults)
//                        topLevelResults = filteredResults
//                    }
                }
            }
        }
        
        // If there are any results that were not filtered into a subgroup then include them at the top level
//        if topLevelResults.filter({ $0.hasResults }).count > 0 {
//            let topResult = createActivityResult(taskResult.identifier, schedule: schedule, stepResults: topLevelResults)
//            allResults.insert(topResult, atIndex: 0)
//        }
        
        return allResults
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        guard let schedule = ctfScheduledActivityAtIndexPath(indexPath) else { return }
//        guard isScheduleAvailable(schedule) else {
//            // Block performing a task that is scheduled for the future
//            let message = messageForUnavailableSchedule(schedule)
//            self.delegate?.showAlertWithOk(nil, message: message, actionHandler: nil)
//            return
//        }
        
        // If this is a valid schedule then create the task view controller
        guard let taskViewController = self.createTaskViewControllerForSchedule(schedule)
            else {
                assertionFailure("Failed to create task view controller for \(schedule)")
                return
        }
        
        self.delegate?.presentViewController(taskViewController, animated: true, completion: nil)
        
    }
    
    func createTask(schedule: CTFScheduledActivity) -> (task: ORKTask?, taskRef: SBATaskReference?) {
        let taskRef = bridgeInfo.taskReferenceWithIdentifier(schedule.taskIdentifier!)
        
        let task = taskRef?.transformToTask(factory: SBASurveyFactory(), isLastStep: true)
        if let surveyTask = task as? SBASurveyTask {
            surveyTask.title = schedule.activity!.label
        }
        return (task, taskRef)
    }
    
    func createTaskViewControllerForSchedule(schedule: CTFScheduledActivity) -> SBATaskViewController? {
        let (inTask, inTaskRef) = self.createTask(schedule)
        guard let task = inTask, let taskRef = inTaskRef else { return nil }
        let taskViewController = self.instantiateTaskViewController(task)
        self.setupTaskViewController(taskViewController, schedule: schedule, taskRef: taskRef)
        return taskViewController
    }
    
    func setupTaskViewController(taskViewController: SBATaskViewController, schedule: CTFScheduledActivity, taskRef: SBATaskReference) {
        taskViewController.scheduledActivityGUID = schedule.guid
        taskViewController.delegate = self
    }
    
    
    func instantiateTaskViewController(task: ORKTask) -> SBATaskViewController {
        return SBATaskViewController(task: task, taskRunUUID: nil)
    }
    
}

extension SBASubtaskStep {
    func filteredTaskResult(inputResult: ORKTaskResult) -> ORKTaskResult {
        // create a mutated copy of the results that includes only the subtask results
        let subtaskResult: ORKTaskResult = inputResult.copy() as! ORKTaskResult
        if let stepResults = subtaskResult.results as? [ORKStepResult] {
            let (subtaskResults, _) = filteredStepResults(stepResults)
            subtaskResult.results = subtaskResults
        }
        return subtaskResult;
    }
    
    func filteredStepResults(inputResults: [ORKStepResult]) -> (subtaskResults:[ORKStepResult], remainingResults:[ORKStepResult]) {
        let prefix = "\(self.subtask.identifier)."
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        var subtaskResults:[ORKStepResult] = []
        var remainingResults:[ORKStepResult] = []
        for stepResult in inputResults {
            if (predicate.evaluateWithObject(stepResult)) {
                stepResult.identifier = stepResult.identifier.substringFromIndex(prefix.endIndex)
                if let stepResults = stepResult.results {
                    for result in stepResults {
                        if result.identifier.hasPrefix(prefix) {
                            result.identifier = result.identifier.substringFromIndex(prefix.endIndex)
                        }
                    }
                }
                subtaskResults += [stepResult]
            }
            else {
                remainingResults += [stepResult]
            }
        }
        return (subtaskResults, remainingResults)
    }
}
