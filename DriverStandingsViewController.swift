//
//  DriverStandingsViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class DriverStandingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var allDrivers: [Driver] = []
    var refreshControl = UIRefreshControl()

    @IBOutlet weak var standingsTableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDrivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = standingsTableView.dequeueReusableCell(withIdentifier: "StandingsTableViewCell", for: indexPath) as! StandingsTableViewCell
        
        FirebaseUtil.getImage(withPath: allDrivers[indexPath.row].Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.imageIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        cell.nameLBL.text = allDrivers[indexPath.row].Name + " " + allDrivers[indexPath.row].Surname
        cell.pointsLBL.text = allDrivers[indexPath.row].TotalPoints + " Pts "
        cell.positionLBL.text = String(indexPath.row+1)
        
        return cell
    }
    
    
    
    
    func orderDriversByTotalPoints(drivers: [Driver]) -> [Driver] {
        return drivers.sorted { (driver1, driver2) in
            guard let points1 = Int(driver1.TotalPoints),
                  let points2 = Int(driver2.TotalPoints) else {
                return false // Handle the case where TotalPoints is not a valid integer
            }
            return points1 > points2
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.setHidesBackButton(false, animated: true)

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
        
        //Obtaining data from API for Drivers
        getDriverData()

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
        let Photo: String
        let Flag: String
        let Points: String
        let TotalPoints: String //INT
    }
    
    
    
    
    
    // ---------------------- API CALL FUNCTIONS
    
    func getDriverData() {
        APIUtil.getAPI(from: "Drivers")
        if let driversData = UserDefaults.standard.string(forKey: "Drivers") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                    allDrivers = orderDriversByTotalPoints(drivers: drivers)
                    standingsTableView.reloadData()
                    print("Lista de Drivers actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Drivers doesn´t exist in UserDefaults")
        }
    }
    
    @objc private func getRefreshData(_ sender: Any) {
        APIUtil.getAPI(from: "Drivers")
        if let driversData = UserDefaults.standard.string(forKey: "Drivers") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                    allDrivers = orderDriversByTotalPoints(drivers: drivers)
                    standingsTableView.reloadData()
                    refreshControl.endRefreshing()
                    print("Lista de Drivers actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Drivers doesn´t exist in UserDefaults")
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
