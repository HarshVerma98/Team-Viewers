//
//  UIVC.swift
//  Hackathon-Sample
//
//  Created by Harsh Verma on 26/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit

extension UIViewController {
    func oneBtn(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let def = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(def)
        present(ac, animated: true, completion: nil)
    }

}
