//
//  EquipmentEditTableViewCell.swift
//  Inspection
//
//  Created by apple on 16/1/17.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentEditTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = EquipmentDB()
        // Initialization code
    }
    
    var DB: EquipmentDB?
    var equipment: Equipment?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextField: UITextField!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
        if let newText = textField.text {
            if  let title = titleLabel.text {
                DB?.editEquipment(equipment!.info.ID, equipmentDetailTitleString: title, newValue: newText)
            }
        }
        return true
    }
}
