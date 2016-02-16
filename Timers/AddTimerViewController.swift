//
//  AddTimerViewController.swift
//  Timers
//
//  Created by Asad Khaliq on 4/29/15.
//  Copyright (c) 2015 Asad Khaliq. All rights reserved.
//

import UIKit
import CoreData

class AddTimerViewController: UIViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    var indexPath : NSIndexPath?
    
    
    @IBOutlet weak var timerName: B68UIFloatLabelTextField!
    @IBOutlet weak var hoursDurationSet: B68UIFloatLabelTextField!
    @IBOutlet weak var minutesDurationSet: B68UIFloatLabelTextField!
    @IBOutlet weak var hoursTargetSet: B68UIFloatLabelTextField!
    @IBOutlet weak var minutesTargetSet: B68UIFloatLabelTextField!
    @IBOutlet weak var colorGridMain: UICollectionView!

    
    var chosenColor : UIColor = UIColor.blackColor()
    var colorItems: [String] = ["#D67D7D","#D67D7D","#D67D7D","#D67D7D","#B1C899","#B1C899","#B1C899","#B2C6DC","#B2C6DC","#B2C6DC"]
    var singleTimer: StoredTimers? = nil
    var name : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if singleTimer != nil {
            timerName.text = singleTimer?.name
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! ColorCollectionViewCell
        
        //cell.gridButton.setTitle("RPRPEPEPEPEPEPEP", forState: UIControlState.Normal)
        cell.backgroundColor = UIColor(rgba: colorItems[indexPath.row])
        
        let layer : CALayer = cell.layer
        layer.cornerRadius = 8.0
        //layer.borderColor = UIColor.colorWithAlphaComponent(UIColor.whiteColor())
        //layer.borderWidth = 1.0
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        chosenColor = UIColor(rgba: colorItems[indexPath.row])
    }
    
    func createBorder(targetField: UITextField) {
        let border = CALayer()
        let width = CGFloat(0.6)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: targetField.frame.size.height - width, width:  targetField.frame.size.width, height: targetField.frame.size.height)
        
        border.borderWidth = width
        targetField.layer.addSublayer(border)
        targetField.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createTask() {
        let entityDescription = NSEntityDescription.entityForName("StoredTimers", inManagedObjectContext: managedObjectContext!)
        let singleTimer = StoredTimers(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        singleTimer.name = timerName.text
        singleTimer.duration = 0
        singleTimer.time = "00:00"
        singleTimer.target = 300
        singleTimer.color = chosenColor
        let currentDate = NSDate()
        singleTimer.sortID = currentDate
        
        do {
            try managedObjectContext?.save()
        } catch _ {
        }

    }
    
    func editTask() {
        singleTimer?.name = timerName.text
        singleTimer?.color = chosenColor
        do {
            try managedObjectContext?.save()
        } catch _ {
        }
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewController()
    }
    
    @IBAction func deleteTimer(sender: AnyObject) {
        dismissViewController()
        let managedObject:NSManagedObject = self.fetchedResultController.objectAtIndexPath(indexPath!) as! NSManagedObject
        self.managedObjectContext?.deleteObject(managedObject)
        do {
            try self.managedObjectContext?.save()
        } catch _ {
        }
    }
    
    
    @IBAction func done(sender: AnyObject) {
        if singleTimer != nil {
            editTask()
        } else {
            createTask()
        }
        dismissViewController()
    }
}

