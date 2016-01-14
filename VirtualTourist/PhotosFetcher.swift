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
    let API_KEY = "ECsA8TFIv9Uij3hULAV4M6nLVYmtHYMSAqgaDDGA"
    
    func searchPhotos(lat: Double, lon: Double, pagesCount: Int, completionHandler: (err: String?, photos: [Photo]?, pagesCount: Int) -> Void){
        let page = Int(arc4random_uniform(UInt32(pagesCount)))+1
        let methodArguments = [
            "consumer_key": API_KEY,
            "rpp": "12",
            "sort": "times_viewed",
            "page": "\(page)",
            "geo": "\(lat),\(lon),\(50)km"
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + METHOD_NAME + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in
                if let error = downloadError {
                    self.updateStatus("Could not complete the request")
                    completionHandler(err: "Could not complete the request \(error)", photos: nil, pagesCount: 1)
                } else {
                    
                    guard let data = data else {
                        self.updateStatus("No data fetched!")
                        completionHandler(err: "No data fetched!", photos: nil, pagesCount: 1)
                        return
                    }
                    let parsedResult: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                    if let resultsArray = parsedResult.valueForKey("photos") as? [[String: AnyObject]] {
                        var photos = [Photo]()
                        self.sharedContext.performBlockAndWait {
                            for item in resultsArray {
                                let photo = Photo(dictionary: item, context: self.sharedContext)
                                photos.append(photo)
                            }
                            var pagesCount = 1
                            if let count = parsedResult.valueForKey("total_pages") as? Int {
                                pagesCount = count
                            }
                            completionHandler(err: nil, photos: photos, pagesCount: pagesCount)
                        }
                    } else {
                        self.updateStatus("JSON response error!")
                        completionHandler(err: "Cant find key 'photos' in \(parsedResult)", photos: nil, pagesCount: 1)
                    }
                }
            }
            task.resume()
        }
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