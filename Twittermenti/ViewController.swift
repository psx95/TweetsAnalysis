//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier: TweetClassifier = TweetClassifier()
    
    let swifter = Swifter(consumerKey: "hHVlyKbpHmydmlYpqTCJhAlki", consumerSecret: "c3iGv8xGqShtdUQ2V2VI2wtUd2M52gQOXMfQNRn643G9vs0Z5j")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let prediction = try! sentimentClassifier.prediction(text: "@Apple is a terrible company")
        //print(prediction.label)
        
        swifter.searchTweet(using: "@Facebook", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            
            var tweets = [TweetClassifierInput]()
            for i in 0..<100 {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassifier = TweetClassifierInput(text: tweet)
                    tweets.append(tweetForClassifier)
                }
            }
            do {
                let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                var predictionScore = 0
                for prediction in predictions {
                    let sentiment = prediction.label
                    if sentiment == "Pos" {
                        predictionScore += 1
                    } else if sentiment == "Neg" {
                        predictionScore -= 1
                    }
                }
                print("\(predictionScore)")
            } catch {
                print("Error making prediction \(error)")
            }
            
        }) { (error) in
            print("Error with twitter APIs \(error)")
        }
    }

    @IBAction func predictPressed(_ sender: Any) {
    
    
    }
    
}

