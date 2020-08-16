//
//  TeamListViewController.swift
//  Hackathon-Sample
//
//  Created by Harsh Verma on 26/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn

class TeamListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var teams: Teams!
    var authUI: FUIAuth!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = self
        teams = Teams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        teams.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeam" {
            let dest = segue.destination as! TeamDetailTableViewController
            let index = tableView.indexPathForSelectedRow!
            dest.team = teams.teamArray[index.row]
        }
    }
    
    func signin() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth(),]
        if authUI.auth?.currentUser == nil {
            self.authUI.providers = provider
            present(authUI.authViewController(), animated: true, completion: nil)
        }else {
            tableView.isHidden = false
        }
    }
    
    @IBAction func signoutBtnPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI.signOut()
            print("Successfully Logged Out!")
            tableView.isHidden = true
            signin()
        }catch {
            tableView.isHidden = true
            print("ERROR: Failed to Sign Out 0x35AC628")
        }
    }
    
}

extension TeamListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.teamArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath)
        cell.textLabel?.text = teams.teamArray[indexPath.row].teamName
        cell.textLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        return cell
    }
}
extension TeamListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false
            print("We have signed in with user: \(user.email ?? "unknown E-Mail")")
        }
    }
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let lvc = FUIAuthPickerViewController(authUI: authUI)
        lvc.view.backgroundColor = UIColor.orange
        let mrg: CGFloat = 16
        let imh: CGFloat = 225
        let iY = self.view.center.y - imh
        let lf = CGRect(x: self.view.frame.origin.x + mrg, y: iY, width: self.view.frame.width - (mrg*2), height: imh)
        let logo = UIImageView(frame: lf)
        logo.image = UIImage(systemName: "stars.fill")
        logo.contentMode = .scaleAspectFit
        lvc.view.addSubview(logo)
        return lvc
    }
    
}
