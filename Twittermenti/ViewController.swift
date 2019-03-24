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

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    let sentimentClassifier: TweetClassifier = TweetClassifier()
    
    let swifter = Swifter(consumerKey: "hHVlyKbpHmydmlYpqTCJhAlki", consumerSecret: "c3iGv8xGqShtdUQ2V2VI2wtUd2M52gQOXMfQNRn643G9vs0Z5j")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundViewTapped () {
        textField.endEditing(true)
    }

    @IBAction func predictPressed(_ sender: Any) {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
                
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
                    if predictionScore > 20 {
                        self.sentimentLabel.text = "😍"
                    } else if predictionScore > 10 {
                        self.sentimentLabel.text = "😀"
                    } else if predictionScore > 0 {
                        self.sentimentLabel.text = "🙂"
                    } else if predictionScore == 0 {
                        self.sentimentLabel.text = "😐"
                    } else if predictionScore > -10 {
                        self.sentimentLabel.text = "😕"
                    } else if predictionScore > -20 {
                        self.sentimentLabel.text = "😡"
                    } else {
                        self.sentimentLabel.text = "🤬"
                    }
                    
                } catch {
                    print("Error making prediction \(error)")
                }
                
            }) { (error) in
                print("Error with twitter APIs \(error)")
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.35) {
            self.heightConstraint.constant = 300
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.35) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }    
}

