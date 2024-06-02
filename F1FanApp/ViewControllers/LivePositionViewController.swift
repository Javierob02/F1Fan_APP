//
//  LivePositionViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 8/3/24.
//

import UIKit

class LivePositionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var taskDone = false
    @IBOutlet weak var positionTableView: UITableView!
    var timer: Timer?   //Timer to load chat messages
    var currentMeetingKey = "";
    
    var stintData: [Stint] = []
    var allStints: [Stint] = []
    
    var positionData: [Position] = []
    var allPositions: [Position] = []
    
    var allDrivers: [Driver] = []
    
    var orderedDriverList: [OrderedDriver] = []
    
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var loadingIMG: UIImageView!
    @IBOutlet weak var loadingLBL: UILabel!
    
    
    //Table View Configuration
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedDriverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = positionTableView.dequeueReusableCell(withIdentifier: "PositionTableViewCell", for: indexPath) as! PositionTableViewCell
        
        FirebaseUtil.getImage(withPath: orderedDriverList[indexPath.row].Photo) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.driverIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        cell.positionLBL.text = String(orderedDriverList[indexPath.row].position)
        //cell.driverLBL.text = orderedDriverList[indexPath.row].Name + " " + orderedDriverList[indexPath.row].Surname
        cell.driverLBL.text = orderedDriverList[indexPath.row].Surname
        //cell.pointsLBL.text = orderedDriverList[indexPath.row].TotalPoints + " Pts "
        cell.tyreLBL.text = orderedDriverList[indexPath.row].compound
        cell.tyreIMG.image = UIImage(named: orderedDriverList[indexPath.row].compound)
        
        cell.accessibilityLabel = orderedDriverList[indexPath.row].Surname + " in position " + String(orderedDriverList[indexPath.row].position) + " with tyre compound " + orderedDriverList[indexPath.row].compound
        
        return cell
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PositionTableViewCell", bundle: nil)
        positionTableView.register(nib, forCellReuseIdentifier: "PositionTableViewCell")
        positionTableView.delegate = self
        positionTableView.dataSource = self
        positionTableView.rowHeight = 114
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hacer aparecer Loader
        loadingContainer.isHidden = false
        loadingIMG.isHidden = false
        loadingLBL.isHidden = false
        
        //Cargar GIF a Loading
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        loadingIMG.image = loadingGIF
        
        if let meeting_key = UserDefaults.standard.string(forKey: "meeting") {
            print("Meeting Key: \(meeting_key)")
            currentMeetingKey = String(meeting_key)
            
            //Get Drivers
            APIUtil.getAPI(from: "Drivers")
            if let driversData = UserDefaults.standard.string(forKey: "Drivers") {
                if let jsonData = driversData.data(using: .utf8) {
                    do {
                        let drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                        allDrivers = drivers
                        print("Lista de Drivers actualizada")
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Drivers doesn´t exist in UserDefaults")
            }
            
            
            
            
            timer?.invalidate()

            // Start a new timer on a background queue that repeats every 3 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                self.refresData()
                //Hacer aparecer Loader
                self.loadingContainer.isHidden = true
                self.loadingIMG.isHidden = true
                self.loadingLBL.isHidden = true
            }

            // Ensure the timer runs on a background queue
            if let timer = timer {
                RunLoop.current.add(timer, forMode: .common)
            }
            
            
        } else {
            print("No meeting key")
        }
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Invalidate the timer when the view controller is about to disappear
        timer?.invalidate()
    }
    
    
//---------------------------------- FUNCTIONS ------------------------
    //Función para refrescar datos
    func refresData() {
        taskDone = false
        
        obtainMeetingPositon()  //Se van llamando una detrás de otra al final de cada función
        
        while (!taskDone) {
            //Wait
        }
        
        positionTableView.reloadData()
    }
    
    //Function to obtain all Stint data from current meeting
    func obtainMeetingStint() {
        APIUtil.getStintData(meetingKey: currentMeetingKey) { result in
            switch result {
            case .success(let data):
                do {
                    let stints = try JSONDecoder().decode([Stint].self, from: data)
                    
                    var driverStint: [Stint] = []
                    
                    //Get latest Stint for each driver
                    for driver in self.allDrivers {
                        driverStint = []
                        for stint in stints {
                            if (String(stint.driver_number) == driver.Number) {
                                driverStint.append(stint)
                            }
                        }
                    self.allStints.append(driverStint[driverStint.count-1])
                    }
                    
                    print("--------- Lista Stints ---------")
                    for i in self.allStints{
                        print(i)
                    }
                    
                    print("Lista de Stints ha sido actualizada")
                    
                    self.getOrderedDrivers()
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching STINT: \(error)")
            }
        
        }
    }
    
    
    //Function to obtain all Position data from current meeting
    func obtainMeetingPositon() {
        APIUtil.getPositionData(meetingKey: currentMeetingKey) { result in
            switch result {
            case .success(let data):
                do {
                    let positions = try JSONDecoder().decode([Position].self, from: data)
                    
                    var driverPositon: [Position] = []
                    
                    //Get latest Stint for each driver
                    for driver in self.allDrivers {
                        driverPositon = []
                        for position in positions {
                            if (String(position.driver_number) == driver.Number) {
                                driverPositon.append(position)
                            }
                        }
                    self.allPositions.append(driverPositon[driverPositon.count-1])
                    }
                    
                    print("--------- Lista Positions ---------")
                    for i in self.allPositions{
                        print(i)
                    }
                    
                    self.obtainMeetingStint()
                    
                    print("Lista de Positions ha sido actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching STINT: \(error)")
            }
        
        }
    }
    
    
    //Function to generate list to pass to TableView
    func getOrderedDrivers() {
        var resultList: [OrderedDriver] = []
        
        for driver in allDrivers {
            let driverStint = allStints.first(where: { String($0.driver_number) == driver.Number })
            let driverPosition = allPositions.first(where: { String($0.driver_number) == driver.Number })
            
            resultList.append(OrderedDriver(position: driverPosition!.position, Photo: driver.Photo, Name: driver.Name, Surname: driver.Surname, Number: driver.Number, compound: driverStint!.compound))
        }
        
        resultList.sort { $0.position < $1.position }
        orderedDriverList = resultList
        print("--------- Lista Ordered Drivers ---------")
        for i in orderedDriverList{
            print(i)
        }
        
        //print("Refrescando Table View")
        taskDone = true
        //positionTableView.reloadData()
    }
    
    
    
    
    
    
//---------------------------------- STRUCT ------------------------
    
    struct Stint: Codable {
        var meeting_key: Int
        var session_key: Int
        var stint_number: Int
        var driver_number: Int
        var lap_start: Int
        var lap_end: Int
        var compound: String
        var tyre_age_at_start: Int

        // Custom initializer to provide default values
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            meeting_key = try container.decodeIfPresent(Int.self, forKey: .meeting_key) ?? 0
            session_key = try container.decodeIfPresent(Int.self, forKey: .session_key) ?? 0
            stint_number = try container.decodeIfPresent(Int.self, forKey: .stint_number) ?? 0
            driver_number = try container.decodeIfPresent(Int.self, forKey: .driver_number) ?? 0
            lap_start = try container.decodeIfPresent(Int.self, forKey: .lap_start) ?? 0
            lap_end = try container.decodeIfPresent(Int.self, forKey: .lap_end) ?? 0
            compound = try container.decodeIfPresent(String.self, forKey: .compound) ?? ""
            tyre_age_at_start = try container.decodeIfPresent(Int.self, forKey: .tyre_age_at_start) ?? 0
        }
    }

    
    struct Position: Codable {
        var session_key: Int
        var meeting_key: Int
        var driver_number: Int
        var date: String
        var position: Int
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
    
    
    struct OrderedDriver: Codable {
        var position: Int
        var Photo: String
        var Name: String
        var Surname: String
        var Number: String
        var compound: String
    }

}
