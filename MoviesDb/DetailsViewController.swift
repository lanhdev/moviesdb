//
//  DetailsViewController.swift
//  MoviesDb
//
//  Created by Macintosh on 10/14/16.
//  Copyright © 2016 Lanh Hoang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
  
  @IBOutlet weak var detailsPosterView: UIImageView!
  @IBOutlet weak var detailsTitleLabel: UILabel!
  @IBOutlet weak var detailsDateLabel: UILabel!
  @IBOutlet weak var detailsRatingLabel: UILabel!
  @IBOutlet weak var detailsOverviewLabel: UILabel!
  @IBOutlet weak var detailsScrollView: UIScrollView!
  @IBOutlet weak var detailsInfoView: UIView!
  
  var movie: NSDictionary!
  let baseUrl = "https://image.tmdb.org/t/p/w342"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    detailsScrollView.contentSize = CGSize(width: detailsScrollView.frame.width, height: detailsInfoView.frame.origin.y + detailsInfoView.frame.height)
    
    let title = movie["title"] as! String
    detailsTitleLabel.text = title
    detailsTitleLabel.sizeToFit()
    
    let date = movie["release_date"] as! String
    detailsDateLabel.text = "Date: \(date)"
    detailsDateLabel.sizeToFit()
    
    let rating = movie["vote_average"] as! Double
    detailsRatingLabel.text = "Rating: \(String(format: "%.2f", rating))"
    detailsRatingLabel.sizeToFit()
    
    let overview = movie["overview"] as! String
    detailsOverviewLabel.text = overview
    detailsOverviewLabel.sizeToFit()
    
    if let posterPath = movie["poster_path"] as? String {
      let posterUrl = baseUrl + posterPath
      detailsPosterView.setImageWith(URL(string: posterUrl)!)
    } else {
      detailsPosterView.image = nil
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
