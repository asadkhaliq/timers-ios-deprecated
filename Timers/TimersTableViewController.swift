//
//  TimersTableViewController.swift
//  Timers
//
//  Created by Asad Khaliq on 4/27/15.
//  Copyright (c) 2015 Asad Khaliq. All rights reserved.
//

import UIKit
import CoreData

class TimersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var timer = NSTimer()
    var lastChosenRow : NSIndexPath?
    var pathModified = 0
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80;
        
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
        
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
        tableView.backgroundColor = UIColor(rgba: "#EDECEC")
        
        tableView.separatorColor = UIColor(rgba: "#EDECEC")
        
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        
        tableView.addGestureRecognizer(longpress)
        
        /*var timer2 = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("someSelector"), userInfo: nil, repeats: false)
        
        func someSelector() {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.5
            fadeTextAnimation.type = kCATransitionFade
            
            self.navigationController!.navigationBar.layer.addAnimation(fadeTextAnimation, forKey: "Timers")
            self.navigationItem.title = "Tuesday June 2"        }*/
        
        
        //tableView.estimatedRowHeight = 60
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "edit" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let taskController:AddTimerViewController = segue.destinationViewController as! AddTimerViewController
            let task:StoredTimers = fetchedResultController.objectAtIndexPath(indexPath!) as! StoredTimers
            taskController.singleTimer = task
            taskController.fetchedResultController = self.fetchedResultController
            taskController.indexPath = indexPath!
        }
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "StoredTimers")
        let sortDescriptor = NSSortDescriptor(key: "sortID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }     
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TimerCell", forIndexPath: indexPath) as? CustomCellMG
        if cell == nil {
            cell = CustomCellMG(style: UITableViewCellStyle.Default, reuseIdentifier: "TimerCell")
        }
        
        let deleteButton = MGSwipeButton(title: " Edit", icon: UIImage(named:"menu@2x.png"), backgroundColor: UIColor.lightGrayColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in

            /*let managedObject:NSManagedObject = self.fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
            self.managedObjectContext?.deleteObject(managedObject)
            self.managedObjectContext?.save(nil)*/
            
            self.performSegueWithIdentifier("edit", sender: cell)

            
            return true
        })
        
        let completeButton = MGSwipeButton(title: " Done", icon: UIImage(named:"check@2x.png"),backgroundColor: UIColor.lightGrayColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            cell!.nameLabel?.text = "Complete"
            
            return true
        })
        
        cell!.rightExpansion.buttonIndex = 0
        cell!.rightExpansion.fillOnTrigger = true
        cell!.rightExpansion.threshold = 1
        cell!.rightExpansion.expansionColor = UIColor.yellowColor()
        //cell?.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        cell!.leftExpansion.buttonIndex = 0
        cell!.leftExpansion.fillOnTrigger = true
        cell!.leftExpansion.threshold = 1
        cell!.leftExpansion.expansionColor = UIColor.greenColor()


        
        cell!.rightButtons = [deleteButton]
        cell!.leftButtons = [completeButton]

        
        
        
        let task = fetchedResultController.objectAtIndexPath(indexPath) as! StoredTimers
        cell!.nameLabel?.text = task.name
        cell!.timeLabel?.text = task.time
        if (task.target != 0) {
            let screenSize: CGRect = UIScreen.mainScreen().bounds //screen size
            let screenWidth = screenSize.width //width of screen for use in target progress bar
            let ratio : Double = Double(task.duration) / Double(task.target)
            cell?.targetBG.frame = CGRect(x: 0, y: 0, width: ratio * Double(screenWidth), height: 80)
        }

        cell!.backgroundColor = task.color as? UIColor
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Do This When The User Clicks The Row
    
        
        if (lastChosenRow == indexPath || pathModified == 0){
            lastChosenRow = indexPath
            pathModified = 1
            let task = fetchedResultController.objectAtIndexPath(lastChosenRow!) as! StoredTimers
            
            if !timer.valid {
                task.time = stringFromTimeInterval(task.duration as NSTimeInterval) as String
                self.tableView.reloadData()
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            }
            else if timer.valid {
                timer.invalidate()
                task.time = stringInactiveFromTimeInterval(task.duration as NSTimeInterval) as String
                self.tableView.reloadData()
                
            }
        }
        else if (lastChosenRow != indexPath) {
            let task = fetchedResultController.objectAtIndexPath(lastChosenRow!) as! StoredTimers
            if timer.valid {
                timer.invalidate()
                task.time = stringInactiveFromTimeInterval(task.duration as NSTimeInterval) as String
                self.tableView.reloadData()
                
            }
            lastChosenRow = indexPath
            let newTask = fetchedResultController.objectAtIndexPath(lastChosenRow!) as! StoredTimers
            if !timer.valid {
                newTask.time = stringFromTimeInterval(newTask.duration as NSTimeInterval) as String
                self.tableView.reloadData()
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        
    }
    
    
    
    func updateTime() {
        let task = fetchedResultController.objectAtIndexPath(lastChosenRow!) as! StoredTimers
        
        var durationCounter = task.duration as Double
        durationCounter++
        task.duration = durationCounter
        
        let finalString = stringFromTimeInterval(task.duration as Double)
        
        task.time = "\(finalString)"
        self.tableView.reloadData()
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        var ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    func stringInactiveFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        var ms = Int((interval % 1) * 1000)
        
        var seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d",hours,minutes)
    }
    
        //MARK: NSFetchedResultsController Delegate Functions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
        }
        
        switch editingStyle {
        case .Delete:
            managedObjectContext?.deleteObject(fetchedResultController.objectAtIndexPath(indexPath) as! StoredTimers)
            do {
                try managedObjectContext?.save()
            } catch _ {
            }
        case .Insert:
            break
        case .None:
            break
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths(NSArray(object: newIndexPath!) as [AnyObject] as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths(NSArray(obje as [AnyObject]ct: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject] as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths(NSArray(object: as [AnyObject] newIndexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Update:
            tableView.cellForRowAtIndexPath(indexPath!)
            break
        default:
            break
        }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    /*@IBAction func done(segue:UIStoryboardSegue) {
    var newItemDetail = segue.sourceViewController as! AddTimerViewController
    var newItem = TimerItem(name: newItemDetail.name, time: "00:00", duration: 0)
    
    timersList.append(newItem)
    
    self.tableView.reloadData()
    
    }*/
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    
    
    /* Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        /*if editingStyle == .Delete {
        // Delete the row from the data source
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        managedObjectContext?.deleteObject(managedObject)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        managedObjectContext?.save(nil)
        */
        
    }*/
    
    
    /*
    - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
    {
    // Delete NSManagedObject
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [context deleteObject:object];
    
    // Save
    NSError *error;
    if ([context save:&error] == NO) {
    // Handle Error.
    }
    }
    
    - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
    atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
    newIndexPath:(NSIndexPath *)newIndexPath
    {
    if (type == NSFetchedResultsChangeDelete) {
    // Delete row from tableView.
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
    withRowAnimation:UITableViewRowAnimationFade];
    }
    }
    */
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
