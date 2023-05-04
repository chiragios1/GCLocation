//
//  Helper.swift
//  LocationTracking
//
//  Created by admin on 02/05/23.
//

import UIKit

class Helper {
   static func getCurrentTimeStampWOMiliseconds(dateToConvert: Date) -> Int {
        let objDateformat: DateFormatter = DateFormatter()
        objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strTime: String = objDateformat.string(from: dateToConvert as Date)
        let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
        let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        //let strTimeStamp: String = "\(milliseconds)"
        return Int(milliseconds)
    }
}
