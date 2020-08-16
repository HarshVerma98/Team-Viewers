//
//  TeamDetailTableViewController.swift
//  Hackathon-Sample
//
//  Created by Harsh Verma on 26/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class TeamDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var universityField: UITextField!
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    
    var team: Team!
    let regionDistance: CLLocationDistance = 5000
    var imagePicker = UIImagePickerController()
    var appImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        if team == nil {
            team = Team()
        }
        team.loadImage {
            self.imageView.image = self.team.appImage
        }
        imagePicker.delegate = self
        let region = MKCoordinateRegion(center: team.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    func updateMapInterface() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(team)
        mapView.setCenter(team.coordinate, animated: true)
    }
    
    func updateUserInterface() {
        teamNameField.text = team.teamName
        universityField.text = team.university
        projectNameField.text = team.projectName
        descriptionTextView.text = team.projectDescription
        updateMapInterface()
    }
    
    func updateFromUI() {
        team.teamName = teamNameField.text!
        team.university = universityField.text!
        team.projectDescription = descriptionTextView.text
        team.projectName = projectNameField.text!
    }
    
    func leaveVC() {
        let isPresent = presentingViewController is UINavigationController
        if isPresent {
            dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func fincLocationPressed(_ sender: UIBarButtonItem) {
        let auto = GMSAutocompleteViewController()
        auto.delegate = self
        present(auto, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveVC()
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUI()
        team.saveData { (success) in
            if success {
                self.team.saveImage { (success) in
                    if !success {
                        print("WARNING FAILED TO SAVE IMAGE:")
                    }
                    self.leaveVC()
                }
            }
        }
    }
    @IBAction func cameraBtnPressed(_ sender: UIBarButtonItem) {
        camAlert()
    }
}
extension TeamDetailTableViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        updateFromUI()
        team.university = place.name ?? "Unknown University"
        team.coordinate = place.coordinate
        //team.projectDescription = "\(team.coordinate.latitude), \(team.coordinate.longitude)"
        updateUserInterface()
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TeamDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let eImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            team.appImage = eImg
        }else {
            if let oImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                team.appImage = oImg
            }
            dismiss(animated: true) {
                self.imageView.image = self.team.appImage
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func camAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "Saved Album", style: .default) { (_) in
            self.accessLib()
        }
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.cameraAccess()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func accessLib() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func cameraAccess() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }else {
            self.oneBtn(title: "Camera not available", message: "Please use original device to use this function")
        }
    }
}
