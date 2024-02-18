//
//  NewsViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/1/24.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var allNews: [News] = []
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var newsTableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        
        cell.titleLBL.text = allNews[indexPath.row].Title
        //cell.dateLBL = String(allNews[indexPath.row].date
        cell.titleLBL.text = allNews[indexPath.row].Title
        cell.contentTV.text = allNews[indexPath.row].Description
        
        FirebaseUtil.getImage(withPath: parseStringToArray(allNews[indexPath.row].Images)[0]) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.newsImageIMG.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        //print(parseStringToArray(allNews[indexPath.row].Images)[0])
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(String(indexPath.row), forKey: "selectedNews")    //Pasa posición de noticia seleccionada
        self.performSegue(withIdentifier: "gotoNews", sender:nil);  //Redirige a siguiente pantalla
        tableView.deselectRow(at: indexPath, animated: true)    //Deselecciona la fila
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NewsTableViewCell
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsTableViewCell")
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.rowHeight = 250
        
        //Add Refresh Control
        refreshControl.addTarget(self, action: #selector(getRefreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.00)
        newsTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Obtaining data from API for Drivers
        getNewsData()
    }
    
    
    
    
    
    
    func parseStringToArray(_ inputString: String) -> [String] {
        // Removing square brackets and whitespaces
        let cleanedString = inputString.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: " ", with: "")
        
        // Splitting the string into an array
        let stringArray = cleanedString.components(separatedBy: ",")
        
        return stringArray
    }
    
    struct News: Codable {
        let idNews: String
        let Title: String
        let Description: String
        let Images: String
        let date: String
    }
    
    
    
    // ---------------------- API CALL FUNCTIONS
    
    func getNewsData() {
        APIUtil.getAPI(from: "News")
        if let driversData = UserDefaults.standard.string(forKey: "News") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let news = try JSONDecoder().decode([News].self, from: jsonData)
                    allNews = news
                    newsTableView.reloadData()
                    //filteredDrivers = allDrivers
                    print("Lista de News actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("News doesn´t exist in UserDefaults")
        }

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    @objc private func getRefreshData(_ sender: Any) {
        APIUtil.getAPI(from: "News")
        if let driversData = UserDefaults.standard.string(forKey: "News") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let news = try JSONDecoder().decode([News].self, from: jsonData)
                    allNews = news
                    //filteredDrivers = allDrivers
                    newsTableView.reloadData()
                    refreshControl.endRefreshing()
                    print("Lista de News actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("News doesn´t exist in UserDefaults")
        }

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
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
