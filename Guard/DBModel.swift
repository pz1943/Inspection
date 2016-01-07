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

    let roomId = Expression<Int64>("roomId")
    let equipmentId = Expression<Int64>("equipmentId")
    let recordId = Expression<Int64>("recordId")
    let roomName = Expression<String>("roomName")
    let equipmentName = Expression<String>("equipmentName")
    let recordMessage = Expression<String>("recordMessage")
    let x = count(*)
    
    struct Constants {
        static let defaultRoom = ["信息北机房","传输机房","电源室","信息南机房"]
        static let defaultEquipmentInRoom1 = ["史图斯空调1","史图斯空调2","史图斯空调3"]
        static let defaultEquipmentInRoom2 = ["艾默生空调1","艾默生空调2","艾默生空调3"]
        static let defaultEquipmentInRoom3 = ["史图斯空调1","史图斯空调2"]
        static let defaultEquipmentInRoom4 = ["史图斯空调1","史图斯空调2","海洛斯空调3"]
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
        
        DB = try! Connection("\(path)/db.sqlite3")
        self.roomTable = Table("roomTable")
        self.equipmentTable = Table("equipmentTable")
        self.recordTable = Table("recordTable")
        
        try! DB.run(roomTable.create(ifNotExists: true) { t in
            print("creat room DB at \(path)")
            t.column(roomId, primaryKey: true)
            t.column(roomName)
            })
        
        try! DB.run(equipmentTable.create(ifNotExists: true) { t in
            print("creat room EQ DB at \(path)")
            t.column(equipmentId, primaryKey: true)
            t.column(equipmentName)
        })
        
        try! DB.run(recordTable.create(ifNotExists: true) { t in
            print("creat room record DB at \(path)")
            t.column(recordId, primaryKey: true)
            t.column(equipmentId)
            t.column(recordMessage)
            })

        initDefaultData()
   }
    
    func initDefaultData() {
        let result = (try! DB.prepare(equipmentTable.count))
        for row: Row in result {
            let countExpression = count(*)
            print(row.get(countExpression))
        }
        
//        for _ in DB.prepare(settingTable) {
//            rowExist = true
//        }
//        if !rowExist {
//            let insert = settingTable.insert(
//                self.selectedChannelIndex <- 0,
//                self.mode <- PlayerMode.FMMode.rawValue)
//            do {
//                try DB.run(insert)
//            } catch let error as NSError {
//                print(error)
//            }
//        }

    }
    
    
//    func loadSettings() -> [String :Int]?{
//        for setting in DB.prepare(settingTable) {
//            return ["selectedChannelIndex": setting[selectedChannelIndex] ,"mode": setting[mode]]
//        }
//        return nil
//    }
//    
//    func saveMode(mode: PlayerMode) {
//        let modeRaw = mode.rawValue
//        try! DB.run(settingTable.update(self.mode <- modeRaw))
//    }
//    
//    func saveSelectedChannelIndex(index: Int) {
//        try! DB.run(settingTable.update(self.selectedChannelIndex <- index))
//    }
//    
//    func loadSongList() -> Array<Song> {
//        var songList: Array<Song> = []
//        var imageCacheData: NSData?
//        for user in DB.prepare(songListTable) {
//            if let imageCacheBytes = user[imageCache]?.bytes {
//                let length = imageCacheBytes.count
//                if length > 0 {
//                    imageCacheData = NSData(bytes: imageCacheBytes, length: length)
//                }
//            }
//            let song =  Song(
//                title: user[title],
//                imageURL: user[imageURL],
//                musicURL: user[musicURL],
//                singer: user[singer],
//                favoriteFlag: user[favoriteFlag],
//                imageCache: imageCacheData,
//                savedName: user[savedName],
//                IsPlaying: user[IsPlaying])
//            songList.insert(song, atIndex: 0)
//        }
//        return songList
//    }
//    
//    
//    
//    func insertSong(newSong: Song) {
//        var rowExist: Bool = false
//        
//        for selection in DB.prepare(songListTable.select(musicURL)) {
//            if selection[musicURL] == newSong.musicURL {
//                rowExist = true
//                print("row exist")
//            }
//        }
//        if rowExist {
//            let alice = songListTable.filter(musicURL == newSong.musicURL)
//            alice.update(savedName <- newSong.savedName)
//        } else {
//            var imageCacheData: Blob?
//            if let data = newSong.imageCache {
//                imageCacheData = Blob(bytes: data.bytes, length: data.length)
//            }
//            let insert = songListTable.insert(
//                self.title <- newSong.title,
//                self.imageURL <- newSong.imageURL,
//                self.musicURL <- newSong.musicURL,
//                self.singer <- newSong.singer,
//                self.favoriteFlag <- newSong.favoriteFlag,
//                self.imageCache <- imageCacheData,
//                self.IsPlaying <- newSong.IsPlaying,
//                self.savedName <- newSong.savedName)
//            do {
//                try DB.run(insert)
//            } catch let error as NSError {
//                print(error)
//            }
//        }
//    }
//    
//    func delSong(musicURL: String) {
//        let alice = songListTable.filter(self.musicURL == musicURL)
//        try! DB.run(alice.delete())
//    }
//    
//    func resetDB() {
//        try! DB.run(songListTable.drop(ifExists: true))
//        try! DB.run(settingTable.drop(ifExists: true))
//        print("DB Droped!")
//    }
}