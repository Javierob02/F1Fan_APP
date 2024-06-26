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
        
        // Extract circuit details
        let circuit = filteredCircuits[indexPath.row]
        let name = circuit.Name
        let date = circuit.Date
        let country = circuit.Country
        let turns = circuit.Turns
        let length = circuit.Length

        // Format the date
        let formattedDate = formatDateUsingSplit(dateString: date)

        // Construct sub-expressions
        let nameWithDate = name + " on day " + formattedDate!
        let countryWithTurns = " in " + country + turns + " Turns"
        let lengthDescription = " and length of " + length + " Kms"

        // Combine sub-expressions to form the final accessibility label
        cell.accessibilityLabel = nameWithDate + countryWithTurns + lengthDescription

        
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
                    allCircuits = sortCircuitsByDate(circuits)    //Actualiza la lista de circuitos
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
    
    
// --------------------- Functions
    func sortCircuitsByDate(_ circuits: [Circuit]) -> [Circuit] {
        // Sort the circuits based on the Date property
        return circuits.sorted { circuit1, circuit2 in
            if let date1 = DateFormatter.customFormat.date(from: circuit1.Date),
               let date2 = DateFormatter.customFormat.date(from: circuit2.Date) {
                return date1 < date2
            }
            return false
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

extension DateFormatter {
    static let customFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
