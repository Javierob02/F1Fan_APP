


//
//  NewsDetailsViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 29/1/24.
//

import UIKit

class NewsDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var chosenNews: News?

    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var myPage: UIPageControl!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var contentTXT: UITextView!
    
    var imageArrays: [UIImage] = []
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parseStringToArray(chosenNews!.Images).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "slide", for: indexPath) as! SliderCell
        
        FirebaseUtil.getImage(withPath: parseStringToArray(chosenNews!.Images)[indexPath.row]) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.images.image = image
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        myPage.currentPage = indexPath.row-1
        print("CURRENT: \(myPage.currentPage)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 80.0, height: collectionView.frame.height)
    }
    
    

    
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedIndex = UserDefaults.standard.string(forKey: "selectedNews") {
            print("SELECTED \(selectedIndex)")
            APIUtil.getAPI(from: "News")
            if let driversData = UserDefaults.standard.string(forKey: "News") {
                if let jsonData = driversData.data(using: .utf8) {
                    do {
                        let news = try JSONDecoder().decode([News].self, from: jsonData)
                        chosenNews = news[Int(selectedIndex)!]
                        titleLBL.text = chosenNews?.Title
                        contentTXT.text = chosenNews?.Description
                        print("Lista de News actualizada")
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("News doesn´t exist in UserDefaults")
            }
        } else {
            //pass
        }
        
        //Load CollectionView
        sliderCollectionView.dataSource = self
        sliderCollectionView.delegate = self
        // Do any additional setup after loading the view.
        myPage.currentPage = 0
        myPage.numberOfPages = parseStringToArray(chosenNews!.Images).count
        if let layout = sliderCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: 340, height: 225) // Set item size to match the size of the image view
            
            // If you want to ensure the image is centered within the image view
            layout.sectionInset = UIEdgeInsets(top: (225 - 225) / 2, left: (340 - 340) / 2, bottom: (225 - 225) / 2, right: (340 - 340) / 2)
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the tab bar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
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
}





