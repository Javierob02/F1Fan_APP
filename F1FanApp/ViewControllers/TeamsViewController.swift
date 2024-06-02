//
//  TeamsViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var allTeams: [Team] = []
    var filteredTeams: [Team] = []
    
    
    @IBOutlet weak var teamsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamsTableView.dequeueReusableCell(withIdentifier: "TeamTableViewCell", for: indexPath) as! TeamTableViewCell
        
        cell.teamLBL.text = filteredTeams[indexPath.row].Name
        cell.driver1NameLBL.text = filteredTeams[indexPath.row].Driver1Name
        cell.driver2NameLBL.text = filteredTeams[indexPath.row].Driver2Name
        
        cell.accessibilityLabel = filteredTeams[indexPath.row].Name + "Drivers " + filteredTeams[indexPath.row].Driver1Name + " and " + filteredTeams[indexPath.row].Driver2Name
        
        FirebaseUtil.getImage(withPath: filteredTeams[indexPath.row].Logo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.logoIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        FirebaseUtil.getImage(withPath: filteredTeams[indexPath.row].Car) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.carIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        FirebaseUtil.getImage(withPath: filteredTeams[indexPath.row].Driver1Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.driver1IMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        FirebaseUtil.getImage(withPath: filteredTeams[indexPath.row].Driver2Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.driver2IMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        return cell
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTeams = []
        
        if searchText == "" {
            filteredTeams = allTeams
        } else {
            for team in allTeams {
                if team.Name.lowercased().contains(searchText.lowercased()) || team.Driver1Name.lowercased().contains(searchText.lowercased()) || team.Driver2Name.lowercased().contains(searchText.lowercased()) {
                    filteredTeams.append(team)
                }
            }
        }
        
        
        self.teamsTableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TeamTableViewCell", bundle: nil)
        teamsTableView.register(nib, forCellReuseIdentifier: "TeamTableViewCell")
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        teamsTableView.rowHeight = 250
        searchBar.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Obtaining data from API for Teams
        getTeamData()
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
        let table = "Teams"
        APIUtil.getAPI(from: table)
        if let teamsData = UserDefaults.standard.string(forKey: table) {
            if let jsonData = teamsData.data(using: .utf8) {
                do {
                    let teams = try JSONDecoder().decode([Team].self, from: jsonData)
                    allTeams = teams    //Actualiza la lista de equipos
                    filteredTeams = teams
                    teamsTableView.reloadData()
                    print("Lista de Teams actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Teams doesn´t exist in UserDefaults")
        }

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
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
