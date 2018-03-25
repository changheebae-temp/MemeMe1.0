//
//  ViewController.swift
//  MemeMe
//
//  Created by Changhee Bae on 25/03/2018.
//  Copyright © 2018 Changhee Bae. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var bottomToolbar: UIToolbar!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var topToolbar: UIToolbar!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  
  // MARK: Properties
  let cameraIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: nil)
  let shareIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: nil)
  let memeTextAttributes:[String: Any] = [
    NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
    NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
    NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedStringKey.strokeWidth.rawValue: -1.5]
  let memedImage = UIImage()
  
  
  // MARK: Life Cycle of Views
  
  override func viewDidLoad() {
    super.viewDidLoad()
    shareButton.isEnabled = false
    setupTextField(textField: topTextField, defaultText: "TOP")
    setupTextField(textField: bottomTextField, defaultText: "BOTTOM")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // UIImagePickerControllerDelegate Instance Methods
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = image
      shareButton.isEnabled = true
    }
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: UITextFieldDelegate Methods
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text == "TOP" || textField.text == "BOTTOM" {
      textField.text = ""
    }
    if textField == topTextField {
      unsubscribeFromKeyboardNotifications()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == topTextField {
      subscribeToKeyboardNotifications()
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  // MARK: Text Field Methods
  
  func setupTextField(textField: UITextField, defaultText: String) {
    textField.delegate = self
    textField.text = defaultText
    textField.defaultTextAttributes = memeTextAttributes
    textField.textAlignment = .center
  }
  
  //MARK: Keyboard Methods
  
  func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
  }
  
  @objc func keyboardWillShow(_ notification:Notification) {
    view.frame.origin.y -= getKeyboardHeight(notification)
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    view.frame.origin.y = 0
  }
  
  func getKeyboardHeight(_ notification:Notification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.cgRectValue.height
  }
  
  // MARK: Meme object
  
  func generateMemeImage() -> UIImage {
    hideBars(true)
    UIGraphicsBeginImageContext(self.view.frame.size)
    view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
    let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    hideBars(false)
    return memedImage
  }
  
  func saveMeme() {
    _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memeImage: memedImage)
  }
  
  func hideBars(_ hidden: Bool) {
    if hidden == true {
      topToolbar.isHidden = true
      bottomToolbar.isHidden = true
    } else {
      topToolbar.isHidden = false
      bottomToolbar.isHidden = false
    }
  }
  
  // MARK: IBActions
  
  @IBAction func pickAnImageFromAlbum(_ sender: Any) {
    presentPicker(withSource: .photoLibrary)
  }
  
  @IBAction func pickAnImageFromCamera(_ sender: Any) {
    presentPicker(withSource: .camera)
  }
  
  // Presenting Picker Method
  func presentPicker(withSource source: UIImagePickerControllerSourceType) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = source
    imagePicker.delegate = self
    present(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func shareMemedImage(_ sender: Any) {
    let memedImage = generateMemeImage()
    let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = self.view
    self.present(activityVC, animated: true, completion: nil)
    activityVC.completionWithItemsHandler = {(activity, completed, items, error) in
      if completed {
        self.saveMeme()
      }
    }
  }
  
  @IBAction func resetMeme(_ sender: Any) {
    shareButton.isEnabled = false
    setupTextField(textField: topTextField, defaultText: "TOP")
    setupTextField(textField: bottomTextField, defaultText: "BOTTOM")
    imageView.image = nil
  }
  
}
