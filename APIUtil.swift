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
    static func postToChatMessages(idUser: String, content: String, timestamp: String) {
        let table = "ChatMessages"
        let url = URL(string: APIUtil.baseURL + table)

        guard let requestURL = url else {
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let postData: [String: Any] = ["iduser": idUser, "Content": content, "timestamp": timestamp]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData)
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response if needed
            if let error = error {
                print("Error posting to ChatMessages: \(error)")
            } else {
                print("Data posted successfully to ChatMessages")
            }
        }

        task.resume()
    }
    

}
