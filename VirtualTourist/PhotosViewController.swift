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
    
    var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes.delegate = self
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "cancelEditing:")
    }
    
    override func viewWillAppear(animated: Bool) {
        view.bringSubviewToFront(placeholder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    func cancelEditing(textField: UITextField) {
        navigationItem.rightBarButtonItem = nil
        view.endEditing(true)
    }
    
}
