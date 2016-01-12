//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by norlin on 06/01/16.
//  Copyright © 2016 norlin. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var notes: UITextView!
    
    var reloadButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes.delegate = self
        
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadPhotos")
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveEditing:")
    }
    
    override func viewWillAppear(animated: Bool) {
        view.bringSubviewToFront(placeholder)
        navigationItem.rightBarButtonItem = reloadButton
        
        guard pin != nil else {
            print("photos view failed!")
            self.dismissViewControllerAnimated(animated, completion: nil)
            return
        }
        
        showPinDetails(pin!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPinDetails(pin: Pin) {
        notes.text = pin.note.text
        placeholder.hidden = notes.hasText()
    }

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
        
        pin!.note.text = notes.text
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // photos methods
    func reloadPhotos(){
        print("TODO: reloadPhotos")
    }
}
