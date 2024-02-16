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
                
                let postData: [String: Any] = ["table": "ChatMessages", "iduser": iduser, "content": message, "timestamp": "2024-02-09 12:00:00"]

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
    
    
    
    
    // --------------------------- STRUCTS
    
    struct ChatUser: Codable {
        let idChatUsers: String
        let Username: String
    }
    
    enum UserError: Error {
        case networkError
        case decodingError
    }
    
}
