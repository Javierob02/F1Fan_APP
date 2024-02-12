//
//  LiveChatViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit
import SwiftUI

class LiveChatViewController: UIViewController {
    //355 opt hight
    var registered = false
    
    @IBOutlet var vcView: UIView!   //Whole View Controller View
    
    //Chat
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTXB: UITextField!
    
    //Chat cover
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var labelTXT: UILabel!
    @IBOutlet weak var usernameTXT: UITextField!
    @IBOutlet weak var joinOUTLET: UIButton!
    
    //Circuit Info
    @IBOutlet weak var circuitNameLBL: UILabel!
    @IBOutlet weak var photoIMG: UIImageView!
    @IBOutlet weak var lapsLBL: UILabel!
    @IBOutlet weak var turnsLBL: UILabel!
    @IBOutlet weak var recordLBL: UILabel!
    @IBOutlet weak var drsLBL: UILabel!
    @IBOutlet weak var lengthLBL: UILabel!
    @IBOutlet weak var countryLBL: UILabel!
    
    
    @IBAction func joinBTN(_ sender: Any) {
        if (usernameTXT.text == "") {
            //Ignorar
            print("Username is Empty");
        } else {
            do {
                APIUtil.postToChatUsers(username: usernameTXT.text!)
                
                registered = !registered
                
                coverView.isHidden = registered
                labelTXT.isHidden = registered
                usernameTXT.isHidden = registered
                joinOUTLET.isHidden = registered
                
                print("You joined the Chat!!");
            } catch {
                print("You cannot Log In to chat");
            }
        }
        
        
    }
    
    @IBAction func sendBTN(_ sender: Any) {
    }
    
    
    
    
    
    
    
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        //Segue to Image Window
        performSegue(withIdentifier: "circuitInfo", sender: photoIMG)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        photoIMG.image = loadingGIF
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setShadow()
        
        //Fetching Data From API
        coverView.isHidden = registered
        labelTXT.isHidden = registered
        usernameTXT.isHidden = registered
        joinOUTLET.isHidden = registered

        // Do any additional setup after loading the view.
        //Obtaining data from API for Circuits
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
                    recordLBL.text = "Record:" + circuitInfo![1]
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
        
        //Image gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        photoIMG.addGestureRecognizer(tapGesture)
        
    }
    
    
// ------- Fucntions
    func closestCircuit(circuits: [Circuit]) -> Circuit? {
        let currentDate = Date()    //Current Date
        var closestCircuit: Circuit?    //Closest circuit
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var timeDifference: TimeInterval = Double.greatestFiniteMagnitude

        for circuit in circuits {       //Loops through all circuits
            let circuitDate = dateFormatter.date(from: circuit.Date)    //Gets circuits date
            
            // Check if the circuit is in the future
            guard let futureDate = circuitDate, futureDate > currentDate else {     //Checks if it is a FUTURE or PAST circuit
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

    
    
    func setShadow() {
        coverView.layer.cornerRadius = 10
        coverView.layer.shadowColor = UIColor.black.cgColor
        coverView.layer.shadowOpacity = 0.5
        coverView.layer.shadowOffset = CGSize(width: 6, height: 6)
        coverView.layer.shadowRadius = 6 // Adjust the shadow spread as needed
        // Optionally, you can add a border to the view
        coverView.layer.borderWidth = 0.7
        coverView.layer.borderColor = UIColor.darkGray.cgColor
        
        messageTableView.layer.cornerRadius = 10
        messageTableView.layer.shadowColor = UIColor.black.cgColor
        messageTableView.layer.shadowOpacity = 0.5
        messageTableView.layer.shadowOffset = CGSize(width: 6, height: 6)
        messageTableView.layer.shadowRadius = 6 // Adjust the shadow spread as needed
        // Optionally, you can add a border to the view
        messageTableView.layer.borderWidth = 0.7
        messageTableView.layer.borderColor = UIColor.darkGray.cgColor
    
    }
    
    
// ---- Keyboard Funtcions
    @objc func keyboardWillShow(_ notification: Notification) {
         if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
             UIView.animate(withDuration: 0.3) {
                 self.vcView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
             }
         }
     }

     @objc func keyboardWillHide(_ notification: Notification) {
         UIView.animate(withDuration: 0.3) {
             self.vcView.transform = .identity
         }
     }

     deinit {
         NotificationCenter.default.removeObserver(self)
     }

    
   
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //Call ChatBox segue
        //performSegue(withIdentifier: "showChat", sender: self)

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
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
    

}


