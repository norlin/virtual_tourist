//
//  PhotosCollectionDelegate.swift
//  VirtualTourist
//
//  Created by norlin on 13/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        let count = sectionInfo.numberOfObjects
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = photosView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCellView
        
        self.sharedContext.performBlockAndWait {
            if let image = photo.image {
                dispatch_async(dispatch_get_main_queue()){
                    cell.image.image = image
                    cell.loader.hidden = true
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    cell.image.image = UIImage(named: "Placeholder")
                    cell.loader.hidden = false
                    cell.loader.startAnimating()
                    photo.fetchImage(){
                        self.sharedContext.performBlockAndWait {
                            let image = photo.image
                            dispatch_async(dispatch_get_main_queue()){
                                cell.image.image = image
                                cell.loader.stopAnimating()
                                cell.loader.hidden = true
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        if let index = selectedItems.indexOf(indexPath) {
            selectedItems.removeAtIndex(index)
            let cell = photosView.cellForItemAtIndexPath(indexPath) as! PhotoCellView
            cell.image.alpha = 1
        } else {
            selectedItems.append(indexPath)
            let cell = photosView.cellForItemAtIndexPath(indexPath) as! PhotoCellView
            cell.image.alpha = 0.6
        }
        
        if (selectedItems.count > 0) {
            deleteLabel.hidden = false
        } else {
            deleteLabel.hidden = true
        }
    }
}