//
//  RaceInfoViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 23/2/24.
//

import UIKit

class RaceInfoViewController: UIViewController {
    var allDrivers: [Driver] = []
    //var sessionInfo: [String] = ["2024-03-08T00:00:00", "2024-03-08T00:00:00", "Race"]
    
    //Circuit Info
    @IBOutlet weak var circuitNameLBL: UILabel!
    @IBOutlet weak var photoIMG: UIImageView!
    @IBOutlet weak var lapsLBL: UILabel!
    @IBOutlet weak var turnsLBL: UILabel!
    @IBOutlet weak var recordLBL: UILabel!
    @IBOutlet weak var drsLBL: UILabel!
    @IBOutlet weak var lengthLBL: UILabel!
    @IBOutlet weak var countryLBL: UILabel!
    
    //Circuit Climatology
    @IBOutlet weak var circuitTimeLBL: UILabel!
    @IBOutlet weak var airTempLBL: UILabel!
    @IBOutlet weak var trackTempLBL: UILabel!
    @IBOutlet weak var humidityLBL: UILabel!
    @IBOutlet weak var pressureLBL: UILabel!
    @IBOutlet weak var windDirectionLBL: UILabel!
    @IBOutlet weak var windSpeedLBL: UILabel!
    
    //Session Info
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    
    //Driver Radio
    @IBOutlet weak var radioBTN: UIButton!
    
    @IBAction func goToRadio(_ sender: Any) {
        performSegue(withIdentifier: "radioPage", sender: photoIMG)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        photoIMG.image = loadingGIF
        
        //Get Circuit Data
        APIUtil.getAPI(from: "Circuits")
        if let circuitsData = UserDefaults.standard.string(forKey: "Circuits") {
            if let jsonData = circuitsData.data(using: .utf8) {
                do {
                    let circuits = try JSONDecoder().decode([Circuit].self, from: jsonData)
                    //Setting current circuit
                    let currentCircuit = closestCircuit(circuits: circuits)
                    let circuitInfo = convertStringToArray(currentCircuit!.ExtraInfo)
                    print(circuitInfo)
                    //Setting data
                    circuitNameLBL.text = currentCircuit?.Name
                    FirebaseUtil.getImage(withPath: currentCircuit!.Photo) { image in
                        if let image = image {
                            DispatchQueue.main.async {
                                //Set ImageName
                                UserDefaults.standard.set(currentCircuit?.Photo, forKey: "currentCircuit")
                                self.photoIMG.image = image
                                print("Image loaded succesfully")
                            }
                        } else {
                            print("Image download failed")
                        }
                    }
                    lapsLBL.text = "Nº Laps: " + circuitInfo![0]
                    turnsLBL.text = "Nº Turns: " + currentCircuit!.Turns
                    recordLBL.text = "Record: " + circuitInfo![1]
                    drsLBL.text = "Nº DRS Zones: " + circuitInfo![2]
                    lengthLBL.text = "Length: " + currentCircuit!.Length
                    countryLBL.text = "Country: " + currentCircuit!.Country
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Circuits doesn´t exist in UserDefaults")
        }
        
        //Get Race Climatology
        APIUtil.getRaceClimatology()
        if let raceClimatology = UserDefaults.standard.string(forKey: "climatology") {
            if let jsonClimaData = raceClimatology.data(using: .utf8) {
                do {
                    let allClimatologies = try JSONDecoder().decode([WeatherData].self, from: jsonClimaData)
                    //Setting current circuit
                    let currentClimatology = allClimatologies[allClimatologies.count-1]
                    
                    //Set all Climatology Labels
                    airTempLBL.text = "Air Temp: " + String(currentClimatology.air_temperature) + "°C"
                    trackTempLBL.text = "Track Temp: " + String(currentClimatology.track_temperature) + "°C"
                    humidityLBL.text = "Humidity: " + String(currentClimatology.humidity)
                    pressureLBL.text = "Pressure: " + String(currentClimatology.pressure) + "Pa"
                    windDirectionLBL.text = "Wind Direction: " + String(currentClimatology.wind_direction) + "°"
                    windSpeedLBL.text = "Wind Speed: " + String(currentClimatology.wind_speed) + "Km/h"
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Circuits doesn´t exist in UserDefaults")
        }
        
        //Get Drivers Data
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
        
        
        //Get Session Data
        APIUtil.getSessionInfo { [weak self] resultString in
            // Check if the resultString is not nil
            if let resultString = resultString {
                let sessionInfo = self!.parseSessionInfo(resultString)

                DispatchQueue.main.async { [weak self] in
                    print("START: " + sessionInfo[0])
                    print("END: " + sessionInfo[1])
                    print("TYPE: " + sessionInfo[2])
                    self?.startDate.text = "Start Time: " +  self!.extractTime(from: sessionInfo[0])!
                    self?.endDate.text = "End Time: " +  self!.extractTime(from: sessionInfo[1])!
                    self?.sessionName.text = "Session Name: " + sessionInfo[2]
                }

                print("Session Info: \(resultString)")
                // Now you can use the resultString as needed, for example, update UI or perform other actions
            } else {
                print("Failed to fetch session info.")
                // Handle the error case, e.g., show an error message to the user
            }
        }

        
        //Image gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        photoIMG.addGestureRecognizer(tapGesture)
    }
    
    
    
// ------- Fucntions
    func parseSessionInfo(_ sessionInfoString: String) -> [String] {
        return sessionInfoString.components(separatedBy: "|")
    }
    
    func extractTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }


    
    func closestCircuit(circuits: [Circuit]) -> Circuit? {
        let currentDate = Date()    //Current Date
        var closestCircuit: Circuit?    //Closest circuit
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var timeDifference: TimeInterval = Double.greatestFiniteMagnitude

        for circuit in circuits {       //Loops through all circuits
            let circuitDate = dateFormatter.date(from: circuit.Date)    //Gets circuits date
            let modifiedDate = Calendar.current.date(byAdding: .day, value: 2, to: circuitDate!)
            
            // Check if the circuit is in the future
            guard let futureDate = modifiedDate, futureDate > currentDate else {     //Checks if it is a FUTURE or PAST circuit
                continue
            }

            let difference = abs(currentDate.timeIntervalSince(futureDate))     //Obtains time difference with circuit

            if difference < timeDifference {    //Keeps track of closest time & circuit
                timeDifference = difference
                closestCircuit = circuit
            }
        }

        return closestCircuit   //Returns closest circuit
    }

    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        //Segue to Image Window
        performSegue(withIdentifier: "circuitInfo", sender: photoIMG)
    }
    
    
    func convertStringToArray(_ input: String) -> [String]? {
        // Remove brackets and split the string by commas
        let components = input
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .components(separatedBy: ", ")

        var resultArray = [Any]()

        for component in components {
            resultArray.append(component)
        }

        return resultArray.isEmpty ? nil : resultArray as! [String]
    }
    

// ----------------------------------- STRUCTS
    
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
    
    struct WeatherData: Codable {
        let air_temperature: Double
        let humidity: Double
        let pressure: Double
        let rainfall: Double
        let track_temperature: Double
        let wind_direction: Double
        let wind_speed: Double
        let date: String
        let session_key: Int
        let meeting_key: Int
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

}
