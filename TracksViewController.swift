//
//  TracksViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class TracksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var allCircuits: [Circuit] = []
    var filteredCircuits: [Circuit] = []
    
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCircuits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: "TracksTableViewCell", for: indexPath) as! TracksTableViewCell
        
        FirebaseUtil.getImage(withPath: filteredCircuits[indexPath.row].Flag) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.flagIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        FirebaseUtil.getImage(withPath: filteredCircuits[indexPath.row].Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.trackIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        cell.countryLBL.text = filteredCircuits[indexPath.row].Country
        cell.dateLBL.text = formatDateUsingSplit(dateString: filteredCircuits[indexPath.row].Date)
        cell.lengthLBL.text = filteredCircuits[indexPath.row].Length + " Kms"
        cell.trackLBL.text = filteredCircuits[indexPath.row].Name
        cell.turnsLBL.text = filteredCircuits[indexPath.row].Turns + " Turns"
        
        return cell
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCircuits = []
        
        if searchText == "" {
            filteredCircuits = allCircuits
        } else {
            for circuit in allCircuits {
                if circuit.Name.lowercased().contains(searchText.lowercased()) || circuit.Country.lowercased().contains(searchText.lowercased()) {
                    filteredCircuits.append(circuit)
                }
            }
        }
        
        
        self.tracksTableView.reloadData()
    }
    
    func formatDateUsingSplit(dateString: String) -> String? {
        let components = dateString.split(separator: " ")
        
        if let firstComponent = components.first {
            return String(firstComponent)
        } else {
            return nil // Invalid date string
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load TableView
        let nib = UINib(nibName: "TracksTableViewCell", bundle: nil)
        tracksTableView.register(nib, forCellReuseIdentifier: "TracksTableViewCell")
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.rowHeight = 240
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Obtaining data from API for Circuits
        getTrackData()

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    
    
    struct Circuit: Codable {
        let idCircuits: String
        let Name: String
        let Country: String
        let Length: String
        let Turns: String
        let Photo: String
        let Flag: String
        let Date: String
        let ExtraInfo: String
    }
    
    
    
    // ---------------------- API CALL FUNCTIONS
    
    func getTrackData() {
        APIUtil.getAPI(from: "Circuits")
        if let circuitsData = UserDefaults.standard.string(forKey: "Circuits") {
            if let jsonData = circuitsData.data(using: .utf8) {
                do {
                    let circuits = try JSONDecoder().decode([Circuit].self, from: jsonData)
                    allCircuits = circuits    //Actualiza la lista de circuitos
                    filteredCircuits = allCircuits
                    tracksTableView.reloadData()
                    print("Lista de Circuits actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Circuits doesn´t exist in UserDefaults")
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
