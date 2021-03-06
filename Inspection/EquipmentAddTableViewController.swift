//
//  equipmentAddTableViewController.swift
//  Inspection
//
//  Created by apple on 16/3/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentAddTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        EQDB = EquipmentDB()
    }

    @IBAction func equipmentAddDone(_ sender: UIBarButtonItem) {
        if let equipmentName = equipmentNameTextField.text {
            if equipmentName != "" && equipmentType != nil {
                EQDB?.addEquipment(equipmentName,equipmentType: equipmentType!, roomID: self.room!.ID, roomName: self.room!.name)
                self.performSegue(withIdentifier: "newEquipmentGotSegue", sender: self)
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBOutlet weak var equipmentNameTextField: UITextField!
    @IBOutlet weak var equipmentTypeLabel: UILabel!
    var EQDB: EquipmentDB?
    var room: Room?
    var equipmentType: String?
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath as NSIndexPath).row == 0 {
            return nil
        } else { return indexPath }
    }
    
    //    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddCell", forIndexPath: indexPath) as! EquipmentAddTableViewCell
    //        return cell
    //    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newEquipmentGotSegue" {
            if let DVC = segue.destination as? EquipmentTableViewController {
                DVC.needRefreshDataFlag = true
            }
        }
    }
    @IBAction func backToEquipmentAddTable(_ segue: UIStoryboardSegue) {
        if segue.identifier == "backToEquipmentAddSegue" {
            self.equipmentTypeLabel.text = self.equipmentType
        } 
    }
}
