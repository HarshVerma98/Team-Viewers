//
//  Teams.swift
//  Hackathon-Sample
//
//  Created by Harsh Verma on 26/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase
class Teams {
    var db: Firestore!
    var teamArray: [Team] = []
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping() -> ()) {
        db.collection("teams").addSnapshotListener { (query, error) in
            guard error == nil else {
                print("** ERROR Adding Snap \(error!.localizedDescription)")
                return completed()
            }
            self.teamArray = []
            for docx in query!.documents {
                let team = Team(dictionary: docx.data())
                team.documentID = docx.documentID
                self.teamArray.append(team)
            }
            completed()
        }
    }
}
