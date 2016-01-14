//
//  PhotosNoteDelegate.swift
//  VirtualTourist
//
//  Created by norlin on 13/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit

extension PhotosViewController: UITextViewDelegate {
    // notes methods
    func textViewDidEndEditing(textView: UITextView) {
        placeholder.hidden = textView.hasText()
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholder.hidden = textView.hasText()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        navigationItem.rightBarButtonItem = cancelButton
        return true
    }
    
    func saveEditing(textField: UITextField) {
        view.endEditing(true)
        navigationItem.rightBarButtonItem = reloadButton
        guard pin != nil else {
            return
        }
        
        self.sharedContext.performBlockAndWait {
            self.pin!.note.text = self.notes.text
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
}
