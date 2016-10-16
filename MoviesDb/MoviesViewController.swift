//
//  MoviesViewController.swift
//  MoviesDb
//
//  Created by Macintosh on 10/14/16.
//  Copyright © 2016 Lanh Hoang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import ReachabilitySwift

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
  @IBOutlet weak var moviesTableView: UITableView!
  @IBOutlet weak var networkErrorView: UIView!
  
  var movies = [NSDictionary]()
  var endpoint: String = "now_playing"
  var searchActive: Bool = false
  var moviesSearch = [NSDictionary]()
  var fullOrFiltered = [NSDictionary]()
  
  let baseUrl = "https://image.tmdb.org/t/p/w342"
  let refreshControl = UIRefreshControl()
  let reachability = Reachability()
  let searchBar = UISearchBar()
  
  struct data {
    static let barColor = UIColor.darkGray
    static let backgroundColor = UIColor.darkGray
    static let textColor = UIColor(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    moviesTableView.dataSource = self
    moviesTableView.delegate = self
    networkErrorView.isHidden = true
    initializeSearchBar()
    loadTheme()
    
    refreshControl.addTarget(self, action: #selector(MoviesViewController.loadMovies), for: UIControlEvents.valueChanged)
    moviesTableView.insertSubview(refreshControl, at: 0)
    
    loadMovies()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(MoviesViewController.reachabilityChanged(note:)), name: ReachabilityChangedNotification, object: reachability)
    do {
      try reachability?.startNotifier()
    } catch {
      print("could not start reachability notifier")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func initializeSearchBar() {
    searchBar.delegate = self
    searchBar.placeholder = "Search"
    navigationItem.titleView = searchBar
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchActive = true
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchActive = false
    searchBar.endEditing(true)
    self.moviesTableView.reloadData()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchActive = false
    searchBar.endEditing(true)
    fullOrFiltered = movies
    searchBar.text = ""
    self.moviesTableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchActive = false
    searchBar.endEditing(true)
    fullOrFiltered = moviesSearch
    searchBar.text = ""
    self.moviesTableView.reloadData()
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchActive = false
    searchBar.endEditing(true)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    moviesSearch = movies.filter({ (text) -> Bool in
      let tmpTitle = text["title"] as! String
      let range = tmpTitle.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
      return range != nil
    })
    if searchText == "" {
      searchActive = false
      fullOrFiltered = movies
    } else {
      searchActive = true
      fullOrFiltered = moviesSearch
    }
    self.moviesTableView.reloadData()
  }
  
  func loadTheme() {
    navigationController?.navigationBar.barTintColor = data.barColor
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: data.textColor]
    navigationController?.navigationBar.tintColor = data.textColor // Set text color for back button
    tabBarController?.tabBar.barTintColor = data.barColor
    tabBarController?.tabBar.tintColor = data.textColor
    view.backgroundColor = data.backgroundColor
  }
  
  func reachabilityChanged(note: NSNotification) {
    let reachability = note.object as! Reachability
    if reachability.isReachable {
      if reachability.isReachableViaWiFi {
        print("Reachable via WiFi")
      } else {
        print("Reachable via Cellular")
      }
    } else {
      print("Network not reachable")
      self.networkErrorView.isHidden = false
    }
  }
  
  func loadMovies() {
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    let request = URLRequest(
      url: url!,
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      timeoutInterval: 10)
    let session = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: nil,
      delegateQueue: OperationQueue.main
    )
    MBProgressHUD.showAdded(to: self.view, animated: true)
    let task: URLSessionDataTask =
      session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! JSONSerialization.jsonObject(
            with: data, options:[]) as? NSDictionary {
//            print("response: \(responseDictionary)")
            self.movies = responseDictionary["results"] as! [NSDictionary]
            self.moviesTableView.reloadData()
            self.refreshControl.endRefreshing()
            self.networkErrorView.isHidden = true
            MBProgressHUD.hide(for: self.view, animated: true)
          }
        }
//         Scenario: When there is no internet connection, stop refresh and hide HUD after pulling to refresh
        guard error == nil else {
          if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
          }
          MBProgressHUD.hide(for: self.view, animated: true)
          return
        }
      })
    task.resume()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchActive {
      return moviesSearch.count
    }
    return movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = moviesTableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
    
    if searchActive {
      fullOrFiltered = moviesSearch
    } else {
      fullOrFiltered = movies
    }
    
    let title = fullOrFiltered[indexPath.row]["title"] as? String
    cell.titleLabel.text = title
    
    let overview = fullOrFiltered[indexPath.row]["overview"] as? String
    cell.overviewLabel.text = overview
    
    if let posterPath = fullOrFiltered[indexPath.row]["poster_path"] as? String {
      let posterUrl = baseUrl + posterPath
      let posterRequest = URLRequest(url: URL(string: posterUrl)!)
      cell.posterView.setImageWith(posterRequest, placeholderImage: nil, success: {
        (imageRequest, imageResponse, image) -> Void in
        
          // imageResponse will be nil if the image is cached
          if imageResponse != nil {
            print("Image was NOT cached, fade in image")
            cell.posterView.alpha = 0.0
            cell.posterView.image = image
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
              cell.posterView.alpha = 1.0
            })
          } else {
            print("Image was cached so just update the image")
            cell.posterView.image = image
          }
        },
          failure: { (imageRequest, imageResponse, error) -> Void in
            // do something for the failure condition
            print("Image is failed to load")
      })
    } else {
      cell.posterView.image = nil
    }

    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    moviesTableView.deselectRow(at: indexPath, animated: true)
  }

  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let cell = sender as! UITableViewCell
    let indexPath = moviesTableView.indexPath(for: cell)
    let movie = searchActive ? moviesSearch[(indexPath?.row)!] : movies[(indexPath?.row)!]

    let detailsVC = segue.destination as! DetailsViewController
    detailsVC.movie = movie
  }
  
  deinit {
    reachability?.stopNotifier()
    NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
  }
  
  
}
