//
//  PhotosFetcher.swift
//  VirtualTourist
//
//  Created by norlin on 12/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import Foundation
import CoreData

class PhotosFetcher {
    let BASE_URL = "https://api.500px.com/v1"
    let METHOD_NAME = "/photos/search"
    //let API_KEY = "YOUR_500px_API_WITHOUT_FU*CKING_YAHOO"
    let API_KEY = "ECsA8TFIv9Uij3hULAV4M6nLVYmtHYMSAqgaDDGA"
    
    func searchPhotos(lat: Double, lon: Double, completionHandler: (err: String?, photos: [Photo]?) -> Void){
        var methodArguments = [
            "consumer_key": API_KEY,
            "rpp": "9",
            "geo": "\(lat),\(lon),\(50)km"
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + METHOD_NAME + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                self.updateStatus("Could not complete the request")
                completionHandler(err: "Could not complete the request \(error)", photos: nil)
            } else {
                
                guard let data = data else {
                    self.updateStatus("No data fetched!")
                    completionHandler(err: "No data fetched!", photos: nil)
                    return
                }
                let parsedResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                if let resultsArray = parsedResult.valueForKey("photos") as? [[String: AnyObject]] {
                    var photos = [Photo]()
                    for item in resultsArray {
                        do {
                            let photo = try Photo(dictionary: item, context: self.sharedContext)
                            photos.append(photo)
                        } catch {
                            print("Can't parse photo: \(item)")
                        }
                    }
                    completionHandler(err: nil, photos: photos)
                } else {
                    self.updateStatus("JSON response error!")
                    completionHandler(err: "Cant find key 'photos' in \(parsedResult)", photos: nil)
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    func updateStatus(text: String){
        print("status: \(text)")
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> PhotosFetcher {
        struct Static {
            static let instance = PhotosFetcher()
        }
    
        return Static.instance
    }
}