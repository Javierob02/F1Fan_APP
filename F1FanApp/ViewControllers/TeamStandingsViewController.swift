//
//  TeamStandingsViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class TeamStandingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var allTeams: [Team] = []
    var refreshControl = UIRefreshControl()

    @IBOutlet weak var standingsTableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = standingsTableView.dequeueReusableCell(withIdentifier: "StandingsTableViewCell", for: indexPath) as! StandingsTableViewCell
        
        FirebaseUtil.getImage(withPath: allTeams[indexPath.row].Car) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.imageIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        cell.nameLBL.text = allTeams[indexPath.row].Name
        cell.pointsLBL.text = allTeams[indexPath.row].TotalPoints + " Pts "
        cell.positionLBL.text = String(indexPath.row+1)
        
        return cell
    }
   
    
    
    func orderTeamsByTotalPoints(teams: [Team]) -> [Team] {
        return teams.sorted { (team1, team2) in
            guard let points1 = Int(team1.TotalPoints),
                  let points2 = Int(team2.TotalPoints) else {
                return false // Handle the case where TotalPoints is not a valid integer
            }
            return points1 > points2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Load TableView
        let nib = UINib(nibName: "StandingsTableViewCell", bundle: nil)
        standingsTableView.register(nib, forCellReuseIdentifier: "StandingsTableViewCell")
        standingsTableView.delegate = self
        standingsTableView.dataSource = self
        standingsTableView.rowHeight = 110
        
        //Add Refresh Control
        refreshControl.addTarget(self, action: #selector(getRefreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        standingsTableView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Obtaining data from API for Teams
        getTeamData()

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    
    struct Team: Codable {
        let idTeams: String //INT
        let Name: String
        let Logo: String
        let Car: String
        let Driver1Name: String
        let Driver1Photo: String
        let Driver2Name: String
        let Driver2Photo: String
        let Points: String
        let TotalPoints: String //INT
    }
    
    
    // ---------------------- API CALL FUNCTIONS
    
    func getTeamData() {
        APIUtil.getAPI(from: "Teams")
        if let teamsData = UserDefaults.standard.string(forKey: "Teams") {
            if let jsonData = teamsData.data(using: .utf8) {
                do {
                    let teams = try JSONDecoder().decode([Team].self, from: jsonData)
                    allTeams = orderTeamsByTotalPoints(teams: teams)
                    standingsTableView.reloadData()
                    print("Lista de Teams actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Teams doesn´t exist in UserDefaults")
        }
    }
    
    @objc private func getRefreshData(_ sender: Any) {
        APIUtil.getAPI(from: "Teams")
        if let teamsData = UserDefaults.standard.string(forKey: "Teams") {
            if let jsonData = teamsData.data(using: .utf8) {
                do {
                    let teams = try JSONDecoder().decode([Team].self, from: jsonData)
                    allTeams = orderTeamsByTotalPoints(teams: teams)
                    standingsTableView.reloadData()
                    refreshControl.endRefreshing()
                    print("Lista de Teams actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Teams doesn´t exist in UserDefaults")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
