//
//  DriversViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class DriversViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var allDrivers: [Driver] = []
    var filteredDrivers: [Driver] = []
    
    @IBOutlet weak var driverTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDrivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = driverTableView.dequeueReusableCell(withIdentifier: "DriverTableViewCell", for: indexPath) as! DriverTableViewCell
        
        FirebaseUtil.getImage(withPath: filteredDrivers[indexPath.row].Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.driverIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        FirebaseUtil.getImage(withPath: filteredDrivers[indexPath.row].Flag) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.flagIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }

        
        cell.driverLBL.text = filteredDrivers[indexPath.row].Name + " " + filteredDrivers[indexPath.row].Surname
        cell.teamLBL.text = filteredDrivers[indexPath.row].TeamName
        cell.numberLBL.text = filteredDrivers[indexPath.row].Number
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDrivers = []
        
        if searchText == "" {
            filteredDrivers = allDrivers
        } else {
            for driver in allDrivers {
                if driver.Name.lowercased().contains(searchText.lowercased()) || driver.Surname.lowercased().contains(searchText.lowercased()) || driver.TeamName.lowercased().contains(searchText.lowercased()) {
                    filteredDrivers.append(driver)
                }
            }
        }
        
        
        self.driverTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load TableView
        let nib = UINib(nibName: "DriverTableViewCell", bundle: nil)
        driverTableView.register(nib, forCellReuseIdentifier: "DriverTableViewCell")
        driverTableView.delegate = self
        driverTableView.dataSource = self
        driverTableView.rowHeight = 520
        searchBar.delegate = self

        //Obtaining data from API for Drivers
        APIUtil.getAPI(from: "Drivers")
        if let driversData = UserDefaults.standard.string(forKey: "Drivers") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                    allDrivers = drivers
                    filteredDrivers = allDrivers
                    print("Lista de Drivers actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Drivers doesn´t exist in UserDefaults")
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    

    
    
    struct Driver: Codable {
        let idDrivers: String   //INT
        let Name: String
        let Surname: String
        let TeamName: String
        let Number: String
        var Photo: String
        var Flag: String
        let Points: String
        let TotalPoints: String //INT
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
