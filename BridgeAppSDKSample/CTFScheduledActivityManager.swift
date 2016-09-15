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
    
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
//        if reason == ORKTaskViewControllerFinishReason.Completed,
//            let schedule = scheduledActivityForTaskViewController(taskViewController)
//            where shouldRecordResult(schedule, taskViewController: taskViewController) {
//            
//            // Update any data stores associated with this task
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: true)
//            
//            // Archive the results
//            let results = activityResultsForSchedule(schedule, taskViewController: taskViewController)
//            let archives = results.mapAndFilter({ archiveForActivityResult($0) })
//            SBADataArchive.encryptAndUploadArchives(archives)
//            
//            // Update the schedule on the server
//            updateScheduledActivity(schedule, taskViewController: taskViewController)
//        }
//        else {
//            taskViewController.task?.updateTrackedDataStores(shouldCommit: false)
//        }
        
        taskViewController.dismissViewControllerAnimated(true) {}
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
