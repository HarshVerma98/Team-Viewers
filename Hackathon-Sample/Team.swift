//
//  Team.swift
//  Hackathon-Sample
//
//  Created by Harsh Verma on 26/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit
class Team: NSObject, MKAnnotation {
    var teamName: String
    var university: String
    var coordinate: CLLocationCoordinate2D
    var projectName: String
    var projectDescription: String
    var postingUserID: String
    var createdOn: Date
    var documentID: String
    var appImage: UIImage
    var appImageUUID: String
    var dict: [String : Any] {
        let timeInterval = createdOn.timeIntervalSince1970
        return ["teamName": teamName, "university": university, "projectName": projectName, "projectDescription": projectDescription, "postingUserID": postingUserID, "createdOn": createdOn, "latitude": latitude, "longitude": longitude, "timeInterval": timeInterval, "appImageUUID": appImageUUID]
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    var title: String? {
        return teamName
    }
    var subtitle: String? {
        return university
    }
    
    init(teamName: String, university: String, coordinate: CLLocationCoordinate2D, projectName: String, projectDescription: String, appImage: UIImage, appImageUUID: String, postingUserID: String, createdOn: Date, documentID: String) {
        self.teamName = teamName
        self.university = university
        self.coordinate = coordinate
        self.projectName = projectName
        self.projectDescription = projectDescription
        self.postingUserID = postingUserID
        self.createdOn = createdOn
        self.appImage = appImage
        self.appImageUUID = appImageUUID
        self.documentID = documentID
    }
    
    convenience override init() {
        self.init(teamName: "", university: "", coordinate: CLLocationCoordinate2D(), projectName: "", projectDescription: "", appImage: UIImage(), appImageUUID: "", postingUserID: "", createdOn: Date(), documentID: "")
    }
    
    
    convenience init(dictionary: [String: Any]) {
        let teamName = dictionary["teamName"] as! String? ?? ""
        let university = dictionary["university"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let projectName = dictionary["projectName"] as! String? ?? ""
        let projectDescription = dictionary["projectDescription"] as! String? ?? ""
        let appImageUUID = dictionary["appImageUUID"] as! String? ?? ""
        let timeInterval = dictionary["timeInterval"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeInterval)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(teamName: teamName, university: university, coordinate: coordinate, projectName: projectName, projectDescription: projectDescription, appImage: UIImage(), appImageUUID: appImageUUID, postingUserID: postingUserID, createdOn: createdOn, documentID: "")
        
    }
    
    func saveData(completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        guard let postinguserid = Auth.auth().currentUser?.uid else {
            print("** ERROR: Could not save due to invalid PostingUserID")
            return completion(false)
        }
        self.postingUserID = postinguserid
        let DSave: [String: Any] = self.dict
        if self.documentID != "" {
            let ref = db.collection("teams").document(self.documentID)
            ref.setData(DSave) { (error) in
                if let ERROR1 = error {
                    print("** ERROR Updating Document \(ERROR1.localizedDescription)")
                    completion(false)
                }else {
                    completion(true)
                }
            }
        }else { // Otherwise create new document
            var ref: DocumentReference? = nil
            ref = db.collection("teams").addDocument(data: DSave) { (error) in
                if let ERR = error {
                    print("***ERROR Adding Document \(ERR.localizedDescription)")
                    completion(false)
                }else {
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    func saveImage(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let str = Storage.storage()
        // converting appImage to Data type
        guard let imageSaver = self.appImage.jpegData(compressionQuality: 0.5) else {
            print("Error Compressing: ")
            return completed(false)
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if appImageUUID == "" {
            // if no UUID then create
            appImageUUID = UUID().uuidString
        }
        //reference creation with UUID
        let ref = str.reference().child(documentID).child(self.appImageUUID)
        let upload = ref.putData(imageSaver, metadata: metadata) { (meta, error) in
            guard error == nil else {
                print("ERROR: \(ref).\(error!.localizedDescription)")
                return completed(false)
            }
            print("Upload worked Metadata is: \(meta)")
        }
        upload.observe(.success) { (snap) in
            // create dictionary
            let DS = self.dict
            let REF = db.collection("teams").document(self.documentID)
            REF.setData(DS) { (error) in
                guard error == nil else {
                    print("Error Observer")
                    completed(false)
                    return
                }
                print("Doc updated with REF ID: \(REF.documentID)")
                completed(true)
                
            }
        }
        upload.observe(.failure) { (snaps) in
            if let error = snaps.error {
                print("Error: \(error.localizedDescription) upload task for file \(self.appImageUUID)")
            }
            return completed(false)
        }
    }
    
    func loadImage(completed: @escaping() -> ()) {
        let storage = Storage.storage()
        let strref = storage.reference().child(self.documentID).child(self.appImageUUID)
        strref.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                print("Error could not load Image from bucket")
                return completed()
            }
            guard let download = UIImage(data: data!) else {
                print("Error converting")
                return completed()
            }
            self.appImage = download
            completed()
        }
    }
}


