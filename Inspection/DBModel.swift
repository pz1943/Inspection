//
//  songListDB.swift
//  DBFM
//
//  Created by apple on 15/12/19.
//  Copyright © 2015年 pz1943. All rights reserved.
//

import Foundation
import SQLite

class DBModel {
    
    var DB: Connection
    var roomTable: Table
    var equipmentTable: Table
    var recordTable: Table

    let roomID = Expression<Int>("roomID")
    let roomName = Expression<String>("roomName")
    
    let equipmentID = Expression<Int>(EquipmentTableColumn.ID.rawValue)
    let equipmentName = Expression<String>(EquipmentTableColumn.Name.rawValue)
    let equipmentBrand = Expression<String?>(EquipmentTableColumn.Brand.rawValue)
    let equipmentModel = Expression<String?>(EquipmentTableColumn.Model.rawValue)
    let equipmentCapacity = Expression<String?>(EquipmentTableColumn.Capacity.rawValue)
    let equipmentCommissionTime = Expression<String?>(EquipmentTableColumn.CommissionTime.rawValue)
    let equipmentSN = Expression<String?>(EquipmentTableColumn.SN.rawValue)
    let equipmentImageName = Expression<String?>(EquipmentTableColumn.ImageName.rawValue)
    
    let recordId = Expression<Int>("recordID")
    let recordMessage = Expression<String?>("recordMessage")

    
   
    struct Constants {
        static let defaultRoom = ["信息北机房","传输机房","电源室","信息南机房"]
        static let defaultEquipmentInRoom = [
            ["北1","北2","北3"],
            ["传1","传2","传3"],
            ["电1","电2"],
            ["南1","南2","南3"]]
    }
    
    struct Static {
        static var instance:DBModel? = nil
        static var token:dispatch_once_t = 0
    }
    
    class func sharedInstance() -> DBModel! {
        dispatch_once(&Static.token) {
            Static.instance = self.init()
        }
        return Static.instance!
    }

    required init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        print("DB at \(path)")

        DB = try! Connection("\(path)/db.sqlite3")
        self.roomTable = Table("roomTable")
        self.equipmentTable = Table("equipmentTable")
        self.recordTable = Table("recordTable")
        
        try! DB.run(roomTable.create(ifNotExists: true) { t in
            t.column(roomID, primaryKey: true)
            t.column(roomName)
            })
        
        try! DB.run(equipmentTable.create(ifNotExists: true) { t in
            t.column(equipmentID, primaryKey: true)
            t.column(equipmentName)
            t.column(roomID)
            t.column(roomName)
            t.column(equipmentBrand)
            t.column(equipmentModel)
            t.column(equipmentCapacity)
            t.column(equipmentCommissionTime)
            t.column(equipmentSN)
            t.column(equipmentImageName)
            })
        
        try! DB.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordId, primaryKey: true)
            t.column(equipmentID)
            t.column(recordMessage)
            })
        initDefaultData()
   }
    
    func initDefaultData() {
        var result = try! DB.prepare(roomTable.count)
        for row: Row in result {
            let countExpression = count(*)
            if row.get(countExpression) == 0 {
                for name in Constants.defaultRoom {
                    let insert = roomTable.insert(self.roomName <- name)
                    do {
                        try DB.run(insert)
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
        result = try! DB.prepare(equipmentTable.count)
        for row: Row in result {
            for var roomIndex = 0; roomIndex < Constants.defaultRoom.count; roomIndex++ {
                let countExpression = count(*)
                if row.get(countExpression) == 0 {
                    for var i = 0; i < Constants.defaultEquipmentInRoom[roomIndex].count; i++ {
                        let insert = equipmentTable.insert(
                            self.roomID <- roomIndex + 1,
                            self.equipmentName <- Constants.defaultEquipmentInRoom[roomIndex][i],
                            self.roomName <- Constants.defaultRoom[roomIndex])
                        do {
                            try DB.run(insert)
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    
    func loadRoomTable() -> [(Int, String)]{
        let rows = Array(try! DB.prepare(roomTable))
        var rooms: [(Int, String)] = [ ]
        for row in rows {
            rooms.append((row[roomID], row[roomName]))
        }
        return rooms
    }
    
    func loadEquipmentTable(roomID: Int) -> [(Int, String)]{
        let rows = Array(try! DB.prepare(equipmentTable.filter(self.roomID == roomID)))
        var equipments: [(Int, String)] = [ ]
        for row in rows {
            equipments.append((row[equipmentID], row[equipmentName]))
        }
        return equipments
    }
    
    
    func loadEquipment(equipmentID: Int) -> Equipment? {
        let row = Array(try! DB.prepare(equipmentTable.filter(self.equipmentID == equipmentID))).first
        if let name =  row?[equipmentName] {
            let locatedRoomID = row?[roomID]
            let locatedRoomName = row?[roomName]
            let brand = row?[equipmentBrand]
            let model = row?[equipmentModel]
            let capacity = row?[equipmentCapacity]
            let commissionTime = row?[equipmentCommissionTime]
            let SN = row?[equipmentSN]
            let ImageName = row?[equipmentImageName]
            
            return Equipment(ID: equipmentID, name: name, roomID: locatedRoomID!, roomName: locatedRoomName!, brand: brand, model: model, capacity: capacity, commissionTime: commissionTime, SN: SN, imageName: ImageName)

        } else {
            return nil
        }
    }

    func editEquipment(equipment: Equipment) {
        let alice = equipmentTable.filter(self.equipmentID == equipment.ID)
        for equipmentDetail in equipment.editableDetailArray {
            do {
                try DB.run(alice.update(Expression<String>("\(equipmentDetail.title.rawValue)") <- equipmentDetail.info))
            } catch let error as NSError {
                print(error)
            }
        }
    }

    func editEquipment(equipmentID: Int, equipmentDetailTitleString: String, newValue: String) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        do {
            if let expressionString = titleStringToExpressionString(equipmentDetailTitleString) {
                if expressionString != EquipmentTableColumn.Name.rawValue {
                    try DB.run(alice.update(Expression<String?>(expressionString) <- newValue))
                    print("\(equipmentID),\(equipmentDetailTitleString),\(newValue)")
                } else {
                    try DB.run(alice.update(Expression<String>(expressionString) <- newValue))
                    print("\(equipmentID),\(equipmentDetailTitleString),\(newValue)")
                }
            }
        } catch let error as NSError {
            print(error)
            print("\(equipmentID),\(equipmentDetailTitleString),\(newValue)")
        }
    }
    
    func titleStringToExpressionString(title: String) -> String? {
        switch title {
        case "设备 ID":
            return EquipmentTableColumn.ID.rawValue
        case "设备名称":
            return EquipmentTableColumn.Name.rawValue
        case "机房 ID":
            return EquipmentTableColumn.RoomID.rawValue
        case "机房名称":
            return EquipmentTableColumn.RoomName.rawValue
        case "设备品牌":
            return EquipmentTableColumn.Brand.rawValue
        case "设备型号":
            return EquipmentTableColumn.Model.rawValue
        case "设备容量":
            return EquipmentTableColumn.Capacity.rawValue
        case "投运时间":
            return EquipmentTableColumn.CommissionTime.rawValue
        case "设备 SN":
            return EquipmentTableColumn.SN.rawValue
        case "图片名称":
            return EquipmentTableColumn.ImageName.rawValue
        default:
            return nil
        }
    }
    
    func addRoom(roomName: String) {
        let insert = roomTable.insert(self.roomName <- roomName)
        do {
            try DB.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }

    func delRoom(roomID: Int) {
        let roomTableAlice = roomTable.filter(self.roomID == roomID)
        do {
            try DB.run(roomTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
        
        let equipmentTableAlice = equipmentTable.filter(self.roomID == roomID)
        do {
            try DB.run(equipmentTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addEquipment(equipmentName: String, roomID: Int, roomName: String) {
        let insert = equipmentTable.insert(
            self.equipmentName <- equipmentName,
            self.roomID <- roomID,
            self.roomName <- roomName)
        do {
            try DB.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }

    func delEquipment(equipmentId: Int) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        do {
            try DB.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
//    func addInspectionRecord(record: String, equipmentID: Int) {
//        
//    }
//    
}

enum EquipmentTableColumn: String{
    case ID = "equipmentID"
    case Name = "equipmentName"
    case RoomID = "roomID"
    case RoomName = "roomName"
    case Brand = "equipmentBrand"
    case Model = "equipmentModel"
    case Capacity = "equipmentCapacity"
    case CommissionTime = "equipmentCommissionTime"
    case SN = "equipmentSN"
    case ImageName = "equipmentImageName"
}

enum EquipmentTableColumnTitle: String{
    case ID = "设备 ID"
    case Name = "设备名称"
    case RoomID = "机房 ID"
    case RoomName = "机房名称"
    case Brand = "设备品牌"
    case Model = "设备型号"
    case Capacity = "设备容量"
    case CommissionTime = "投运时间"
    case SN = "设备 SN"
    case ImageName = "图片名称"
}

enum InspectionType {
    case Daily
    case Weekly
    case FilterChanging
    case Cleaning
    case BeltChanging
    case HumidifyingCansChanging
}