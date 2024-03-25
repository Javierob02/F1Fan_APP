//
//  APIUtil.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//https://levelup.gitconnected.com/swift-making-an-api-call-and-fetching-json-acd364c77a71

import Foundation

class APIUtil {
    static let baseURL = "http://localhost/F1API/api.php?table="
    static let soloURL = "http://localhost/F1API/api.php"
    
    //Function to get Data from table <table>
    static func getAPI(from table: String){
        guard let url = URL(string: APIUtil.baseURL+table) else{
            return
        }
        
        print("fetching from: \(url)")
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            
            if let data = data, let result = String(data: data, encoding: .utf8){
                UserDefaults.standard.set(result, forKey: table)    //Guarda en el UserDefaults <table>
            }
        }
        
        task.resume()
    }
    
    
    
    // Function to post data to ChatUsers table
    static func postToChatUsers(username: String) {
        let url = URL(string: APIUtil.soloURL)
        
        guard let requestURL = url else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postData: [String: Any] = ["table": "ChatUsers", "username": username]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData)
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error posting to ChatUsers: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                // Parse the response JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Check if the response indicates success
                    if let successMessage = json["success"] as? String {
                        print(successMessage)
                        
                        // If success, you can extract additional information if needed
                        if let idChatUsers = json["idChatUsers"] as? Int {
                            print("idChatUsers: \(idChatUsers)")
                            UserDefaults.standard.set(String(idChatUsers), forKey: "userID")
                        }
                    } else {
                        print("Error in response format.")
                    }
                } else {
                    print("Unable to parse JSON response.")
                }
            } catch {
                print("Error decoding JSON response: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    
    // Function to post data to ChatMessages table
    static func postToChatMessages(username: String, message: String) {
        let url = URL(string: APIUtil.soloURL)
        var iduser = "3333333"

        guard let requestURL = url else {
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Obtain Users ID from Username     --------------> DATE()
        getUserId(forUsername: username) { result in
            switch result {
            case .success(let userId):
                if let userId = userId {
                    print("User ID: \(userId) for USERNAME: \(username)")
                    iduser = userId
                } else {
                    print("User not found.")
                    iduser = "99999"
                }
                
                //DateFormatter for Date() --> String()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let postData: [String: Any] = ["table": "ChatMessages", "iduser": iduser, "content": message, "timestamp": dateFormatter.string(from: Date())]      //Message to be sent

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: postData)
                } catch {
                    print("Error encoding JSON: \(error)")
                    return
                }

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error posting to ChatMessages: \(error)")
                        return
                    }

                    guard let data = data else {
                        print("No data received.")
                        return
                    }

                    do {
                        // Parse the response JSON
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // Check if the response indicates success
                            if let successMessage = json["success"] as? String {
                                print(successMessage)
                            } else {
                                print("Error in response format.")
                            }
                        } else {
                            print("Unable to parse JSON response.")
                        }
                    } catch {
                        print("Error decoding JSON response: \(error)")
                    }
                }

                task.resume()
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
    
    
    
    
    // ---------------------------- FUNCTIONS
    
    static func getUserId(forUsername username: String, completion: @escaping (Result<String?, UserError>) -> Void) {
        let apiUrl = "http://localhost/F1API/api.php?table=ChatUsers"
        
        guard let url = URL(string: apiUrl) else {
            completion(.failure(.networkError))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkError))
                return
            }

            do {
                let users = try JSONDecoder().decode([ChatUser].self, from: data)

                if let userId = users.first(where: { $0.Username == username })?.idChatUsers {
                    completion(.success(userId))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    
    static func getUsername(forUserId userId: String) -> String? {
        let apiUrl = "http://localhost/F1API/api.php?table=ChatUsers"
        
        guard let url = URL(string: apiUrl) else {
            return "network error"
        }

        do {
            let data = try Data(contentsOf: url)
            let users = try JSONDecoder().decode([ChatUser].self, from: data)

            if let username = users.first(where: { $0.idChatUsers == userId })?.Username {
                print("USERID: \(userId) = USERNAME: \(username)")
                return username
            } else {
                return nil
            }
        } catch {
            print("Error during data task: \(error)")
            return "network error"
        }
    }
    
    
    
    //API function to get latest Race Climatology
    static func getRaceClimatology() {
        // API URL
        let apiUrl = "https://api.openf1.org/v1/weather?meeting_key=latest"

        // Create URL object
        if let url = URL(string: apiUrl) {
            // Create a URLSession task to get the data
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                // Check if data is available
                guard let data = data else {
                    print("No data received")
                    return
                }

                // Convert data to JSON string
                if let jsonString = String(data: data, encoding: .utf8) {
                    // Store the JSON string in UserDefaults
                    UserDefaults.standard.set(jsonString, forKey: "climatology")
                    print("Data stored in UserDefaults as JSON string")
                }
            }.resume()
        }
    }
    
    
    
    //API function to get latest Driver Radio
    static func getDriverRadio(driverNumber: String) {
        // API URL
        let apiUrl = "https://api.openf1.org/v1/team_radio?driver_number=" + driverNumber
        print("FETCHING FROM: \(apiUrl)")

        // Create URL object
        if let url = URL(string: apiUrl) {
            // Create a URLSession task to get the data
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                // Check if data is available
                guard let data = data else {
                    print("No data received")
                    return
                }

                // Convert data to JSON string
                if let jsonString = String(data: data, encoding: .utf8) {
                    // Store the JSON string in UserDefaults
                    UserDefaults.standard.set(jsonString, forKey: "radio")
                    print("Data stored in UserDefaults as JSON string")
                }
            }.resume()
        }
    }
    
    
    // API function to get Session Info
    static func getSessionInfo(completion: @escaping (String?) -> Void) {
        // API URL
        let apiUrl = "https://api.openf1.org/v1/sessions"
        print("FETCHING FROM: \(apiUrl)")

        // Create URL object
        if let url = URL(string: apiUrl) {
            // Create a URLSession task to get the data
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(nil)
                    return
                }

                // Check if data is available
                guard let data = data else {
                    print("No data received")
                    completion(nil)
                    return
                }

                do {
                    // Decode data directly to [SessionInfo]
                    let allSessions = try JSONDecoder().decode([SessionInfo].self, from: data)

                    // Obtaining latest radio
                    let latestSession = allSessions.last
                    
                    //Save meeting_key
                    let meeting_key = String(latestSession!.meeting_key)
                    UserDefaults.standard.set(meeting_key, forKey: "meeting")

                    // Set AUDIO
                    let resultString = "\(latestSession?.date_start ?? "")|\(latestSession?.date_end ?? "")|\(latestSession?.session_name ?? "")"
                    print(resultString)
                    completion(resultString)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(nil)
                }
            }.resume()
        }
    }
    
    
    
    
    //API function to get latest Position Data
    static func getPositionData(meetingKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // API URL
        let apiUrl = "https://api.openf1.org/v1/position?meeting_key=" + meetingKey
        print("FETCHING FROM: \(apiUrl)")

        // Create URL object
        if let url = URL(string: apiUrl) {
            // Create a URLSession task to get the data
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(.failure(error))
                    return
                }

                // Check if data is available
                guard let data = data else {
                    print("No data received")
                    let noDataError = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                    return
                }

                // Call the completion handler with the result
                completion(.success(data))
            }.resume()
        }
    }
    
    
    //API function to get latest Stint Data
    static func getStintData(meetingKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // API URL
        let apiUrl = "https://api.openf1.org/v1/stints?meeting_key=" + meetingKey
        print("FETCHING FROM: \(apiUrl)")

        // Create URL object
        if let url = URL(string: apiUrl) {
            // Create a URLSession task to get the data
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(.failure(error))
                    return
                }

                // Check if data is available
                guard let data = data else {
                    print("No data received")
                    let noDataError = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                    return
                }

                // Call the completion handler with the result
                completion(.success(data))
            }.resume()
        }
    }





    
    
    
    
    // --------------------------- STRUCTS
    
    struct ChatUser: Codable {
        let idChatUsers: String
        let Username: String
    }
    
    struct SessionInfo: Codable {
        var session_key: Int
        var session_name: String
        var date_start: String
        var date_end: String
        var gmt_offset: String
        var session_type: String
        var meeting_key: Int
        var location: String
        var country_key: Int
        var country_code: String
        var country_name: String
        var circuit_key: Int
        var circuit_short_name: String
        var year: Int
    }
    
    enum UserError: Error {
        case networkError
        case decodingError
    }
    
}
