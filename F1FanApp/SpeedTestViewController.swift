//
//  SpeedTestViewController.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 23/1/24.
//

import UIKit

class SpeedTestViewController: UIViewController {
    
    var lightsImages = ["Lights1", "Lights2", "Lights3", "Lights4", "Lights5"]
    
    enum State {
        case idle
        case running
        case waiting
    }

    var state: State = .idle
    let LIGHT_ON_INTERVAL: TimeInterval = 1000  //1 Segundo
    var nextLightStrip = 0
    var result = "00.000"
    var jumpStarted = false
    var startTime: Date?
    var timerId: Timer?
    var fuzzerId: Timer?
    var best: TimeInterval = UserDefaults.standard.double(forKey: "best") {
        didSet {
            UserDefaults.standard.set(best, forKey: "best")
        }
    }
    
    @IBOutlet weak var lightsImg: UIImageView!
    @IBOutlet weak var timerTXT: UILabel!
    @IBOutlet weak var bestTimeTXT: UILabel!
    
    
    func start() {
        nextLightStrip = 0
        jumpStarted = false
        
        result = "00.000"
        timerTXT.text = result
        startTime = nil

        turnOnNextLight()


    }

    @objc func turnOnNextLight() {
        guard nextLightStrip < 5 else {
            // If all lights are turned on, perform the actions for fuzzedLightsOut
            fuzzedLightsOut()
            return
        }
        
        let workItem = DispatchWorkItem {
            guard !self.jumpStarted else {
                // If cancellation flag is set, stop further execution
                    print("Jumpstarted")
                return
            }

            self.lightsImg.image = UIImage(named: self.lightsImages[self.nextLightStrip])
            print("CHANGING lights")
            self.nextLightStrip += 1
            self.turnOnNextLight()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }


    func fuzzedLightsOut() {
        // random time between 4-7 sec
        let fuzzyInterval = Double.random(in: 2400...4200)
        print("Time before lights out: " + String(fuzzyInterval))
        fuzzerId = Timer.scheduledTimer(withTimeInterval: fuzzyInterval / 1000.0, repeats: false) { [weak self] _ in
            self?.clearLights()
            self?.startTime = Date()
            self?.state = .waiting
        }
    }

    func clearLights() {
        // Assuming $refs.lights is an array of light views
        // You should replace this with your actual view references
        lightsImg.image = UIImage(named: "Lights0")
        timerTXT.text = "00.000"
    }
    
    
    func format(ms: TimeInterval) -> String {
        // Convert milliseconds to seconds.milliseconds format
        let secs = String(format: "%06.3f", ms)
        return secs
    }
    
    func manageBestTime(_ newTime: String) {
        let bestTime = getBestTime()
        
        if bestTime == "00.000" {   //Si best es 00.000, entonces se ponde el nuevo tiempo obtenido
            saveBestTime(newTime)
        } else {
            let timeA = TimeInterval(newTime) ?? 0.0  //NEW
            let timeB = TimeInterval(getBestTime()!) ?? 0.0  //OLD

            let smallerTime = min(timeA, timeB)
            let result = String(format: "%06.3f", smallerTime)
            saveBestTime(result)   //Se pone el tiempo más rápido
        }
    }
    
// ----- Manage best time in Local Storage -----
    func saveBestTime(_ time: String) {
        UserDefaults.standard.set(time, forKey: "bestTime")
    }

    func getBestTime() -> String? {
        return UserDefaults.standard.string(forKey: "bestTime")
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        switch state {
            case .running:
                state = .idle
                result = "JUMP START!"
                jumpStarted = true  //It has Jump Started
                //timerId?.invalidate()
                fuzzerId?.invalidate()
                timerTXT.text = result
                lightsImg.image = UIImage(named: "Lights0")
            case .idle:
                state = .running
                start()
            case .waiting:
                state = .idle
                if let startTime = startTime {
                    let timeDiff = Date().timeIntervalSince(startTime)
                    result = format(ms: timeDiff)
                     timerTXT.text = result
                     manageBestTime(result)
                     let bestTime = getBestTime()
                    bestTimeTXT.text = "Your best: \(bestTime ?? "00.000")"
                    best = best == 0 ? timeDiff : min(best, timeDiff)
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lightsImg.image = UIImage(named: "Lights0")
        timerTXT.text = "00.000"
        if let bestTime = getBestTime() {
            //If there is a Best Time
            bestTimeTXT.text = "Your best: \(bestTime)"
        } else {
            //If there is no Best Time yet
            saveBestTime("00.000")
            bestTimeTXT.text = "Your best: 00.000"
        }
        //saveBestTime("01.000")

        // Do any additional setup after loading the view.
        
        // Create a UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)   // Add the gesture recognizer to the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
