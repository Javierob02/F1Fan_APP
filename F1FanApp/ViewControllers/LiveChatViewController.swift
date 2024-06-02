//
//  LiveChatViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit
import SwiftUI

class LiveChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //355 opt hight
    var registered = false
    var currentUsername = ""
    var currentUserId = ""
    var orderedMessages: [ChatMessage] = [ChatMessage(message: "", isUser: false, username: "")]
    var chatJoinTimestamp: Date? = nil
    var timer: Timer?   //Timer to load chat messages
    var newMessages: [ChatMessage] = []    //create new list of messages
    
    @IBOutlet var vcView: UIView!   //Whole View Controller View
    
    //Chat
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTXB: UITextField!
    @IBOutlet weak var exitBTN: UIButton!
    
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
    
    
// -------------- CHAT TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Size ARRAY: \(orderedMessages.count)")
        return orderedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        if (orderedMessages[indexPath.row].isUser) {    //My Message
            cell.messageTXT.textAlignment = .right
            cell.usernameTXT.textAlignment = .right
            cell.usernameTXT.text = orderedMessages[indexPath.row].username
            cell.messageTXT.text = orderedMessages[indexPath.row].message
            cell.usernameTXT.textColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)   //Set text to signatura red
        } else {    //Others Message
            cell.messageTXT.textAlignment = .left
            cell.usernameTXT.textAlignment = .left
            cell.usernameTXT.text = orderedMessages[indexPath.row].username
            cell.messageTXT.text = orderedMessages[indexPath.row].message
            cell.usernameTXT.textColor = UIColor.black
        }
        
        print("ROW: \(indexPath.row) | MESSAGE: \(orderedMessages[indexPath.row].message)")
        
        return cell
    }
    
// ---------------------------------
    
    
    @IBAction func joinBTN(_ sender: Any) {
        if (usernameTXT.text == "") {       //Doesn´t enter CHAT
            //Ignorar
            print("Username is Empty");
        } else {    //Enters CHAT
            do {
                chatJoinTimestamp = Date()  //Gets chat join timestamp
                print("Joined chat on: \(chatJoinTimestamp)")
                
                APIUtil.postToChatUsers(username: usernameTXT.text!)
                currentUsername = usernameTXT.text!
                usernameTXT.text = ""
                
                registered = !registered
                
                coverView.isHidden = registered
                labelTXT.isHidden = registered
                usernameTXT.isHidden = registered
                joinOUTLET.isHidden = registered
                exitBTN.isHidden = !registered
                
                print("You joined the Chat!!");
                
                let chatManager = self
                chatManager.startChat()
                RunLoop.main.run()
                
            } catch {
                print("You cannot Log In to chat");
            }
        }
        
        
    }
    
    @IBAction func sendBTN(_ sender: Any) {
        APIUtil.postToChatMessages(username: currentUsername, message: messageTXB.text!)
        print("-------- Sending Message --------")
        print("USER: \(currentUsername)");
        print("Message: \(messageTXB.text!)");
        messageTXB.text = "";
    }
    
    @IBAction func exitChat(_ sender: Any) {
        //Stop Timer
        stopChat()
        //Marcar como No Registrado
        registered = !registered
        //Hide Chat + Return Join Page
        coverView.isHidden = registered
        labelTXT.isHidden = registered
        usernameTXT.isHidden = registered
        joinOUTLET.isHidden = registered
        //Restart Variables
        currentUsername = ""
        currentUserId = ""
        //Esconder botón de "Exit Chat"
        exitBTN.isHidden = !registered
        
        print("You have left the Chat!!");
    }
    
    
// ----------------------- Chat Logic
    
    func startChat() {
        // Invalidate any existing timer before starting a new one
        timer?.invalidate()

        // Start a new timer on a background queue that repeats every 1 second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.loadChat(self.messageTableView)
        }

        // Ensure the timer runs on a background queue
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    func stopChat() {
        // Stop the timer when needed
        timer?.invalidate()
    }
    
    
    func loadChat(_ tableView: UITableView) {
        
        if (self.currentUserId == "") {  // Si no tenemos nuestro User_Id, lo obtenemos
            APIUtil.getUserId(forUsername: self.currentUsername) { result in
                switch result {
                case .success(let userId):
                    if let userId = userId {
                        print("User ID: \(userId) for USERNAME: \(self.currentUsername)")
                        self.currentUserId = userId  // Obtenemos el ID del remitente
                        
                        self.messageGet()  // Llamamos a messageGet() para obtener los mensajes
                        
                    } else {
                        print("User not found.")
                        self.currentUserId = "99999"  // Establecemos un ID por defecto si el usuario no es encontrado
                    }
                case .failure(let error):
                    print("Error: \(error)")  // Imprimimos el error si falla la llamada a la API
                }
            }
        } else {  // Si ya tenemos el User_Id
            messageGet()  // Llamamos a messageGet() para obtener los mensajes
        }
    }

    
    
    // --------- Chat Utility Functions
    
    func messageGet() {
        self.newMessages = []
        
        APIUtil.getAPI(from: "ChatMessages")
        if let chatMessages = UserDefaults.standard.string(forKey: "ChatMessages") {
            if let jsonData = chatMessages.data(using: .utf8) {
                do {
                    let messages = try JSONDecoder().decode([ChatMessages].self, from: jsonData)
                    
                    for message in messages {
                        //Check for message timestamp (MessageTimestamp >= ChatJoinTimestamp)
                        if (compareDates(stringToDate(timestamp: message.Timestamp), self.chatJoinTimestamp)) {      //Message is a new message
                            //Gets Users Username
                            
                            
                            let messageUser = APIUtil.getUsername(forUserId: message.iduser)
                            
                            let chatMessage = ChatMessage(message: message.Content, isUser: self.currentUserId == message.iduser, username: messageUser!)    //Crea mensaje ordenado
                            self.newMessages.append(chatMessage)     //Añade el mensaje a la lista de ordenados
                            print("NewMessages    ADDED: \(self.newMessages)")
                            print("AÑADIENDO: \(chatMessage.message), USER: \(chatMessage.username)")
                            
                        } else {    //It is an old message
                            //Ignorar el mensaje
                        }
                    }
                    
                    print("NewMessages: \(self.newMessages)")
                    self.orderedMessages = self.newMessages
                    print("LISTA DE MENSAJES: \(self.orderedMessages)")
                    
                    messageTableView.reloadData()
                    scrollToBottom()
                    
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Chat is Disconnected")
        }
    }
    
    
    
    func stringToDate(timestamp: String) -> Date? {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            return dateFormatter.date(from: timestamp)
    }
    
    func compareDates(_ date1: Date?, _ date2: Date?) -> Bool {
        // If either date is nil, return false
        guard let unwrappedDate1 = date1, let unwrappedDate2 = date2 else {
            return false
        }
        
        // Use the comparison operator on the unwrapped dates
        return unwrappedDate1 >= unwrappedDate2
    }
    
    
    
    
    
    
    
    
// ------------------------------------
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        photoIMG.image = loadingGIF
        
        //Delete all messages from chat
        UserDefaults.standard.set("", forKey: "ChatMessages")    //Guarda en el UserDefaults <table>
        
        let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTableView.register(nib, forCellReuseIdentifier: "MessageTableViewCell")
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setShadow()
        
        //Fetching Data From API
        coverView.isHidden = registered
        labelTXT.isHidden = registered
        usernameTXT.isHidden = registered
        joinOUTLET.isHidden = registered
        exitBTN.isHidden = !registered

        // Do any additional setup after loading the view.
        
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
        //performSegue(withIdentifier: "circuitInfo", sender: photoIMG)
        performSegue(withIdentifier: "raceInfo", sender: photoIMG)
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
    
    func scrollToBottom() {
        if orderedMessages.count > 0 {
            let indexPath = IndexPath(row: orderedMessages.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
// ---- Keyboard Funtcions
    @objc func keyboardWillShow(_ notification: Notification) {
         if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
             UIView.animate(withDuration: 0.3) {
                 self.vcView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
                 self.lapsLBL.isHidden = true
                 self.turnsLBL.isHidden = true
                 self.lengthLBL.isHidden = true
                 self.countryLBL.isHidden = true
                 self.recordLBL.isHidden = true
                 self.drsLBL.isHidden = true
             }
         }
     }

     @objc func keyboardWillHide(_ notification: Notification) {
         UIView.animate(withDuration: 0.3) {
             self.vcView.transform = .identity
             self.lapsLBL.isHidden = false
             self.turnsLBL.isHidden = false
             self.lengthLBL.isHidden = false
             self.countryLBL.isHidden = false
             self.recordLBL.isHidden = false
             self.drsLBL.isHidden = false
         }
     }

     deinit {
         NotificationCenter.default.removeObserver(self)
     }

    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        self.messageTableView?.reloadData()

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
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
    
    struct ChatMessage {
        let message: String
        let isUser: Bool
        let username: String
    }
    
    struct ChatMessages: Codable {
        let idChatMessages: String
        let iduser: String
        let Content: String
        let Timestamp: String
    }
    
    struct ChatUser: Codable {
        let idChatUsers: String
        let Username: String
    }
    

}


