//
//  QRCodeTableViewController.swift
//  Inspection
//
//  Created by mac-pz on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class QRCodeForAnyEquipmentTableViewController: QRCodeRecordTableViewController { }

class QRCodeRecordTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        record = InspectionRecord(equipmentID: equipment!.ID, type: inspectionTypeArrayForEQ.first?.inspectionTypeName ?? "无", recordData: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getNewMessage:", name: "newRecordGotNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeRecordType:", name: "changeRecordTypeNotification", object: nil)
        selectFirst()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = equipment!.roomName + equipment!.name
    }
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    var equipmentID: Int? {
        didSet {
            DB = DBModel.sharedInstance()
            if equipmentID != nil {
                equipment = DB!.loadEquipment(equipmentID!)
                inspectionTypeArrayForEQ = DB!.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(equipment?.type)
            }
        }
    }
    var equipment: Equipment?
    var DB: DBModel?
    var record: InspectionRecord?
    var inspectionTypeArrayForEQ: [InspectionType] = []

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func selectFirst() {
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    func getNewMessage(notification: NSNotification) {
        if let recordMessage = notification.userInfo?["recordMessage"] {
            record?.message = recordMessage as? String
        }
    }
    
    func changeRecordType(notification: NSNotification) {
        if let newType = notification.userInfo?["recordType"] as? String {
            record?.recordType = newType
        }
        reloadTableView()
    }
    func reloadTableView() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerReloadTableView", userInfo: nil, repeats: false)
    }
    func timerReloadTableView() {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return inspectionTypeArrayForEQ.count
        } else { return 1 }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InspectionTypeCell", forIndexPath: indexPath)
            cell.textLabel?.text = inspectionTypeArrayForEQ[indexPath.row].inspectionTypeName
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) as! QRCodeTableViewCell
            cell.recordType.text = record?.recordType
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "  巡检类型"
        case 1:
            return "  巡检记录"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 100
        } else { return tableView.rowHeight }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        record?.recordType = inspectionTypeArrayForEQ[indexPath.row].inspectionTypeName
        reloadTableView()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QRDone" {
            DB?.addInspectionRecord(record!)
        }
    }
}
