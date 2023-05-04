//
//  GCLocation.swift
//  LocationTracking
//
//  Created by admin on 02/05/23.
//

import Foundation
import CoreLocation
import CoreData
import  Alamofire
import CocoaLumberjack
import CocoaLumberjackSwift
import OSLog
import Darwin
import CommonCrypto
import CryptoKit
import os
import BackgroundTasks
import Reachability
import  UIKit
import ZipArchive
@available(macOS 11.0, *)
public class GCLocation: NSObject {
   // var locationObject = [Locationwithtimestamp]()
    public lazy var cdsLocationWithTimestamp: CoreDataStack = .init(modelName: "LocationWithTimestamp")
    public  var locationManager:CLLocationManager?
    public var timer = Timer()
    public  let formatter = DateFormatter()
   

    // Parse two times as strings
    public  let time1String = "13:30"
    public  let time2String = "14:45"
    enum ApplicationState {
        case active
        case inactive
        case background

       
        init() {
            switch UIApplication.shared.applicationState {
            case .active:
                self = .active
            case .inactive:
                self = .inactive
            case .background:
                self = .background
            @unknown default:
                fatalError()
            }
        }
        
        public func toString() -> String {
                switch self {
                case .active:
                    return "Active"
                case .inactive:
                    return "Inactive"
                case .background:
                    return "Background"
                }
            }
    }
    public  static let shared = GCLocation()
        
        private override init() {
            super.init()
            let consoleLogger = DDOSLogger.sharedInstance
            DDLog.add(consoleLogger)
            

        }
    
    public func startTracking(){
        let calendar = Calendar.current
        let now = Date()

        _ = calendar.startOfDay(for: now)
        let ninePmToday = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now)!
      //  let eightAmTomorrow = calendar.date(byAdding: .day, value: 1, to: midnightToday)!
        let eightAmToday = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!

        if now >= ninePmToday || now < eightAmToday {
            timer = Timer.scheduledTimer(timeInterval: 3600.0, target: self, selector: #selector(startLocation), userInfo: nil, repeats: true)


        } else {
            timer = Timer.scheduledTimer(timeInterval:15.0, target: self, selector: #selector(startLocation), userInfo: nil, repeats: true)


        }
    }
    
    
    public func setUserId(clintName: String) {
        let dict = ["client_name" : clintName] as [String : Any]
        AlamoFireCommon.PostURL(url: "client", dict: dict) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    self.callAPIForGETclient(data["Id"] as! String)
                    
                }
            }
            
        }
    }
    public func GetLogFile(){
        let logFileLogger = DDFileLogger()
        print(logFileLogger.logFileManager.logsDirectory)
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Documents directory not found")
        }
        let zipPath = "\(documentsURL.path)/archive.zip"
        let zipURL = URL(fileURLWithPath: zipPath)
        let success = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: logFileLogger.logFileManager.sortedLogFilePaths)

        if success {
            print("Archive created successfully")
            let activityVC = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                // Find the relevant window
                if let viewController = windowScene.windows.first?.rootViewController {
                    // Present the activity view controller
                    viewController.present(activityVC, animated: true, completion: nil)
                }
            }
            // Present the activity view controller
           
        } else {
            print("Failed to create archive")
        }
        for path in logFileLogger.logFileManager.sortedLogFilePaths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                print(content)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
           
            
        }
    }
    
// MARK -  OTHER METHODS
    ///// OTHER METHODS
    
    @objc  func startLocation() {
         LocationManager.shared.getLocation { [self] (location:CLLocation?, error:NSError?) in
             if let error = error {
                // self.alertMessage(message: error.localizedDescription, buttonText: "OK", completionHandler: nil)
                // DDLog.sharedInstance.logError("\(error.localizedDescription)")
                 DDLogError("\(error.localizedDescription)")
                 
                 return
             }
             guard let location = location else {
                // DDLog.sharedInstance().logError("Unable to fetch location")
                 DDLogError("Unable to fetch location")
            
                 
                 return
             }
            
             print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
             
             
             let s = RelativeMap().hash(Lat: location.coordinate.latitude, Lon: location.coordinate.longitude, UserID: UserDefaults.standard.string(forKey: "user_id")!)

             
           
             callAPIForPlaceStore(geoHash: s)
             let managedContext = self.cdsLocationWithTimestamp.managedContext
             let newLocation = Locationwithtimestamp(context: managedContext)
             newLocation.longitude = location.coordinate.latitude
             newLocation.latitude = location.coordinate.longitude
             newLocation.timestamp = Date()
             newLocation.applicationState  = ApplicationState().toString()
            
             cdsLocationWithTimestamp.saveContext()
            
             
         }
     }
    
  //// WEB API public funcTIONs
    public func callAPIForPlaceStore(geoHash : String){
        
        let dict = ["positions" :[["customer_id" : UserDefaults.standard.string(forKey: "user_id")!,"geo_hash":geoHash, "tstmp" : Helper.getCurrentTimeStampWOMiliseconds(dateToConvert: Date()) ]]] as [String : Any]
        
        AlamoFireCommon.PostURL(url: "position", dict: dict) { responceData, success, error in
            if success
            {
                var status = 0
                if let code = responceData["status"] as? Int
                {
                    status = code
                }
                if status == 200
                {
                    
                }
            } else {
                let managedContext =  self.cdsLocationWithTimestamp.managedContext
               
                let newLocation = LocationUpdateFailur(context: managedContext)
                newLocation.customer_id = (dict["positions"] as! [[String: Any]])[0]["customer_id"] as? String
                newLocation.geo_hash = (dict["positions"] as! [[String: Any]])[0]["geo_hash"] as? String
                newLocation.tstmp = Int16(truncatingIfNeeded: (dict["positions"] as! [[String: Any]])[0]["tstmp"] as! Int)
                self.cdsLocationWithTimestamp.saveContext()
                
                
            }
        }
    }
    public func callAPIForGETclient(_ clientID : String){
        AlamoFireCommon.GetURL(url: "client/\(clientID)", dict: [:]) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let Token = (data["Token"] as? String) {
                        
                        UserDefaults.standard.set(Token, forKey: "Token")
                        self.callAPIForCreateCustomerID(clientID)
                    }
                }
                
                
                
               
                
            }
        }
       

    }
    public func callAPIForCreateCustomerID(_ clientID : String){
        let dict = ["client_Id" : clientID] as [String : Any]
        AlamoFireCommon.PostURL(url: "customer", dict: dict) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let clientID = (data["Id"] as? String) {
                        self.callAPIForGetCustomer(clientID)
                    }
                    
                }
                

                
                
               
                
            }
        }
       

    }
    public func callAPIForGetCustomer(_ CustomerID : String){
        
        AlamoFireCommon.GetURL(url: "customer/\(CustomerID)", dict: [:]) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let customerID = (data["Id"] as? String) {
                        
                        UserDefaults.standard.set(customerID, forKey: "user_id")
                    }
                }
                
            }
        }
       

    }
}

