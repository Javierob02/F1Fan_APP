//
//  RadioListenViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 24/2/24.
//

import UIKit
import AVKit

class RadioListenViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var allDrivers: [Driver] = []
    let playImage = UIImage(systemName: "play.fill")
    let pauseImage = UIImage(systemName: "pause.fill")
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    @IBOutlet weak var driverPicker: UIPickerView!
    @IBOutlet weak var driverIMG: UIImageView!
    @IBOutlet weak var audioInfoLBL: UILabel!
    @IBOutlet weak var audioSLDR: UISlider!
    @IBOutlet weak var playPauseBTN: UIButton!
    
    
// --------- Manage Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allDrivers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allDrivers[row].Name + " " + allDrivers[row].Surname
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        audioSLDR.value = 0 //Set Slider to 0
        FirebaseUtil.getImage(withPath: allDrivers[row].Photo) { image in
            if let image = image {
                DispatchQueue.main.async { [self] in
                    driverIMG.image = image         //Set IMAGE
                    print("Image loaded succesfully")
                }
            } else {
                print("Image download failed")
            }
        }
        //Get Radio Data
        APIUtil.getDriverRadio(driverNumber: allDrivers[row].Number)
        audioInfoLBL.text = "Loading Radio..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in     //Adds 2 second delay for updating UserDefaults
            if let radioData = UserDefaults.standard.string(forKey: "radio") {
                if let jsonRadioData = radioData.data(using: .utf8) {
                    do {
                        let allRadios = try JSONDecoder().decode([RadioData].self, from: jsonRadioData)
                        // Obtaining latest radio
                        print(allRadios)
                        let latestRadio = allRadios[allRadios.count-1]
                        // Set AUDIO
                        setupAudioPlayer(radioURL: latestRadio.recording_url)
                        audioInfoLBL.text = convertDateString(latestRadio.date)
                        print(latestRadio.recording_url)
                        print(radioData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Circuits doesn't exist in UserDefaults")
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        driverPicker.delegate = self
        driverPicker.dataSource = self
        
        //Set up GIF Loader
        let loadingGIF = UIImage.gifImageWithName("LoadingTransparent")
        driverIMG.image = loadingGIF
        
        //Get Driver Data
        APIUtil.getAPI(from: "Drivers")
        if let driversData = UserDefaults.standard.string(forKey: "Drivers") {
            if let jsonData = driversData.data(using: .utf8) {
                do {
                    let drivers = try JSONDecoder().decode([Driver].self, from: jsonData)
                    allDrivers = drivers
                    //Set All Elements to First element of "allDrivers"
                    FirebaseUtil.getImage(withPath: allDrivers[0].Photo) { image in
                        if let image = image {
                            DispatchQueue.main.async { [self] in
                                driverIMG.image = image
                                print("Image loaded succesfully")
                            }
                        } else {
                            print("Image download failed")
                        }
                    }
                    //Reload UIPickerView
                    driverPicker.reloadAllComponents()
                    print("Lista de Drivers actualizada")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        } else {
            print("Drivers doesn´t exist in UserDefaults")
        }
        //Get Radio Data
        APIUtil.getDriverRadio(driverNumber: allDrivers[0].Number)
        audioInfoLBL.text = "Loading Radio..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in     //Adds 2 second delay for updating UserDefaults
            if let radioData = UserDefaults.standard.string(forKey: "radio") {
                if let jsonRadioData = radioData.data(using: .utf8) {
                    do {
                        let allRadios = try JSONDecoder().decode([RadioData].self, from: jsonRadioData)
                        // Obtaining latest radio
                        let latestRadio = allRadios[allRadios.count-1]
                        // Set AUDIO
                        setupAudioPlayer(radioURL: latestRadio.recording_url)
                        audioInfoLBL.text = convertDateString(latestRadio.date)
                        print(latestRadio.recording_url)
                        print(radioData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Circuits doesn't exist in UserDefaults")
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    
    
// -------------- Functions
    
    func convertDateString(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
            return outputFormatter.string(from: date)
        } else {
            return nil  // Invalid input string format
        }
    }
        
    func setupAudioPlayer(radioURL: String) {
        guard let audioURL = URL(string: radioURL) else {
            return
        }
        playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) { [weak self] time in
            let duration = CMTimeGetSeconds((self?.player?.currentItem?.duration)!)
            let currentTime = CMTimeGetSeconds(time)
            let progress = Float(currentTime / duration)
            self?.audioSLDR.value = progress
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
         if player?.rate == 0 { //It is paused
             player?.play()
             playPauseBTN.setImage(pauseImage, for: .normal)
             print("PLAY")
         } else {       //It is playing
             player?.pause()
             playPauseBTN.setImage(playImage, for: .normal)
             print("PAUSE")
         }
     }

     @IBAction func sliderValueChanged(_ sender: UISlider) {
         if let duration = player?.currentItem?.duration {
             let totalSeconds = CMTimeGetSeconds(duration)
             let value = Float64(sender.value) * totalSeconds
             let seekTime = CMTime(value: Int64(value), timescale: 1)
             player?.seek(to: seekTime)
         }
     }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        audioSLDR.value = 0 //Set Slider to 0
        player?.seek(to: CMTime.zero)
        playPauseBTN.setImage(playImage, for: .normal)
    }
    
    
    
    
    
    
    
    
    
// ------------- Struct
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
    
    struct RadioData: Codable {
        let date: String
        let driver_number: Int
        let session_key: Int
        let meeting_key: Int
        let recording_url: String
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
