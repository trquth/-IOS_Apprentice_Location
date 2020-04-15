//
//  LocationDetailsVC.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/12/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
     let formatter = DateFormatter()
     formatter.dateStyle = .medium
     formatter.timeStyle = .short
     return formatter }()

class LocationDetailsVC: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var  imageHeight:  NSLayoutConstraint!
    var image: UIImage?
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext : NSManagedObjectContext!
    var date = Date()
    var locationToEdit : Location? {
        didSet {
            if let location = locationToEdit  {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
            
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        }else{
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: Date())
        
        categoryLabel.text = categoryName
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        dateLabel.text = format(date: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerVC
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
    }
    @IBAction func done(_ sender: Any) {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
    
        let location : Location
        if let temp  = locationToEdit {
            hudView.text = "Updated"
            location = temp
        }else{
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark  = placemark
        
        if let image = image {
           if !location.hasPhoto {
             location.photoID = Location.nextPhotoID() as NSNumber
           }
            if let data = image.jpegData(compressionQuality: 0.5) {
             do {
               try data.write(to: location.photoURL, options: .atomic)
             } catch {
               print("Error writing file: \(error)")
             }
           }
         }
        
        do {
            try managedObjectContext.save()
            let delayInSeconds = 0.6
            afterDelay(0.6, run: {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            })
        } catch  {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue){
        let controller = segue.source as! CategoryPickerVC
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
        }
    }
    
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare { text += s + " " }
        if let s = placemark.thoroughfare { text += s + ", " }
        if let s = placemark.locality { text += s + ", " }
        if let s = placemark.administrativeArea { text += s + " " }
        if let s = placemark.postalCode { text += s + ", " }
        if let s = placemark.country { text += s }
        return text
    }
    
    func format(date: Date) -> String {
      return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath?.section == 0 && indexPath?.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
}

extension LocationDetailsVC:  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func takePhotoWithCamera()  {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto()  {
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        }else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in self.takePhotoWithCamera()})
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in self.choosePhotoFromLibrary()})
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    
    func show(image : UIImage)  {
        imageView.image = image
        imageView.isHidden = false
        imageHeight.constant = 260
        tableView.reloadData()
        //addPhotoLabel.text = ""
    }
    
    func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main){_ in if self.presentedViewController != nil{
            self.dismiss(animated: false, completion: nil)
            }
            self.descriptionTextView.resignFirstResponder()
        }
    }
}
