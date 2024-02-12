//
//  FirebaseUtil.swift
//  F1FanApp
//
//  Created by Javier Ocón Barreiro on 26/1/24.
//

import UIKit
import Foundation
import Firebase
import FirebaseStorage

class FirebaseUtil {
    
    static let imageCache = NSCache<NSString, UIImage>()

    static func getImage(withPath path: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: path as NSString) {  //Image is CACHED
            // If the image is in cache, return it immediately
            print("IMAGE \(path).png is in CACHE")
            completion(cachedImage)
        } else {    //Image is Not CACHED
            let storage = Storage.storage(url: "gs://f1fans-aa206.appspot.com")
            let reference = storage.reference(withPath: path + ".png")
            print("Fetching: \(reference)")

            reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    if let data = data, let image = UIImage(data: data) {
                        // Cache the image for future use
                        imageCache.setObject(image, forKey: path as NSString)
                        print("Passing IMAGE: \(reference)")
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    /*static func getImage(withPath path: String, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage(url: "gs://f1fans-aa206.appspot.com")
        let reference = storage.reference(withPath: path + ".png")
        print("Fetching: \(reference)")

        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {      //Error happens
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let data = data, let image = UIImage(data: data) {
                    print("Passing IMAGE: \(reference)")
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }*/
    
    
    //Obtiene la imagen de Firebase y si está en la caché se obtiene de ahí
    //E.g. de path: "drivers/lando-norris" OR "flags/uk"
    /*static func getImage(withPath path: String, completion: @escaping (UIImage?) -> Void) {
        // Check if the image is in the cache
        let pathIMG = path + ".png"
        print("PATH: " + pathIMG)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: pathIMG)!)),
           let image = UIImage(data: cachedResponse.data) {
            print("Image: \(pathIMG) obtained from CACHE")
            completion(image)
            return
        }

        print("Image: \(pathIMG) not found in CACHE")

        let storage = Storage.storage(url: "gs://f1fans-aa206.appspot.com")
        let reference = storage.reference(withPath: pathIMG)

        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let data = data, let image = UIImage(data: data) {
                    // Store the image in the cache
                    let cachedResponse = CachedURLResponse(response: URLResponse(url: URL(string: pathIMG)!, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil), data: data)
                    URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: URL(string: pathIMG)!))
                    print("Image: \(pathIMG) obtained from FIREBASE")

                    completion(image)
                } else {
                    print("ERROR: Response was ot able to convert into Image")
                    completion(nil)
                }
            }
        }
    }*/
    
    
    
    /*static func getImage(withPath path: String, completion: @escaping (UIImage?) -> Void) {
        // Check if the image is in the cache
        let pathIMG = path + ".png"
        print("PATH: " + pathIMG)

        if let url = URL(string: pathIMG) {
            let request = URLRequest(url: url)

            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               let httpResponse = cachedResponse.response as? HTTPURLResponse {
                // Check Cache-Control headers
                if let cacheControl = httpResponse.allHeaderFields["Cache-Control"] as? String,
                   cacheControl.contains("max-age=3600") {
                    // Use the cached image
                    let cachedImage = UIImage(data: cachedResponse.data)
                    print("Image: \(pathIMG) obtained from CACHE")
                    completion(cachedImage)
                    return
                }
            }

            print("Image: \(pathIMG) not found in CACHE")

            // If not in the cache or cache is stale, fetch from Firebase
            let storage = Storage.storage(url: "gs://f1fans-aa206.appspot.com")
            let reference = storage.reference(withPath: pathIMG)

            reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    if let data = data, let image = UIImage(data: data) {
                        // Store the image in the cache
                        let response = URLResponse(
                            url: url,
                            mimeType: "image/png",
                            expectedContentLength: data.count,
                            textEncodingName: nil
                        )

                        // Store Cache-Control header based on your server's response
                        let cacheControlHeader = "max-age=3600" // Adjust as per your server configuration

                        // Store the response in the cache
                        URLCache.shared.storeCachedResponse(
                            CachedURLResponse(response: response, data: data),
                            for: request
                        )

                        print("Image: \(pathIMG) obtained from FIREBASE")
                        completion(image)
                    } else {
                        print("ERROR: Response was not able to convert into Image")
                        completion(nil)
                    }
                }
            }
        } else {
            print("ERROR: Invalid URL")
            completion(nil)
        }
    }*/

    
    
    
}
