//
//  DiscoveryViewController.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import ScrollingStackContainer
import CoreLocation

class DiscoverPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var topicModel = TopicsModelManager.shared
    private var restaurantModel = RestaurantsModelManager.shared
    private var displayedTopics = TopicsModelManager.shared.getShortList(Constants.DiscoveryPage.numOfDisplayedTopics)
    private var displayedRestaurants = RestaurantsModelManager.shared.getShortList(Constants.DiscoveryPage.numOfDisplayedRestaurants)
    
    private var currentTopic: Topic?
    private var currentRestaurant: Restaurant?
    var currentUser: User?
    
    private var postsTableController: PostsTableController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topicList: UICollectionView!
    @IBOutlet weak var restaurantList: UICollectionView!
    @IBOutlet weak var postsArea: UIView!
    //SCROLL IMPLEMENTATION
    private var postsTable: UITableView!
    @IBOutlet weak var postAreaHeight: NSLayoutConstraint!
    //==========================
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topicList {
            return displayedTopics.count
        }
        if collectionView == restaurantList {
            return displayedRestaurants.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topicList {
            return getCellForTopic(collectionView, indexPath)
        }
        if collectionView == restaurantList {
            return getCellForRestaurant(collectionView, indexPath)
        }
        
        return UICollectionViewCell()
    }
    
    private func getCellForTopic(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.topicShortListCell, for: indexPath as IndexPath) as! TopicShortListCell
        
        if !displayedTopics.isEmpty {
            cell.setImage(displayedTopics[indexPath.item].getImageAsUIImage())
            cell.setName(displayedTopics[indexPath.item].getName())
        }
        cell.layer.masksToBounds = false
        return cell
    }
    
    private func getCellForRestaurant(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.restaurantShortListCell, for: indexPath as IndexPath) as! RestaurantShortListCell
        if !displayedRestaurants.isEmpty {
            cell.setImage(displayedRestaurants[indexPath.item].getImage())
            cell.setName(displayedRestaurants[indexPath.item].getName())
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topicList {
            self.currentTopic = Topic(displayedTopics[indexPath.item])
            performSegue(withIdentifier: Identifiers.discoveryToTopicPage, sender: self)
        } else if collectionView == restaurantList {
            self.currentRestaurant = Restaurant(displayedRestaurants[indexPath.item])
            performSegue(withIdentifier: Identifiers.discoveryToRestaurantPage, sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.displayedTopics = TopicsModelManager.shared.getShortList(Constants.DiscoveryPage.numOfDisplayedTopics)
        self.displayedRestaurants = RestaurantsModelManager.shared.getShortList(Constants.DiscoveryPage.numOfDisplayedRestaurants)
        self.restaurantList.reloadData()
        self.topicList.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        initPosts()
        //change of poststable controller
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func initPosts() {
        //change of poststable controller
        postsTableController = Bundle.main.loadNibNamed("PostsTable", owner: nil, options: nil)?.first as! PostsTableController
        postsTableController.setParentController(self)
        postsTableController.getTrendingPosts()
        self.addChildViewController(postsTableController!)
        
        postsTableController.setScrollDelegate(self)
        postsTable = postsTableController.getTable()
        postAreaHeight.constant = postsTable.contentSize.height + CGFloat(150)
        postsTableController.view.frame.size = postsArea.frame.size
        postsArea.addSubview(postsTableController.view)
        postsTable.bounces = false
        postsTable.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicViewController {
            dest.setTopic(self.currentTopic)
            dest.tabBarController?.tabBar.isHidden = false
        }
        if let dest = segue.destination as? TopicListController {
            dest.tabBarController?.tabBar.isHidden = false
        }
        if let dest = segue.destination as? RestaurantViewController {
            dest.setRestaurant(self.currentRestaurant)
            dest.tabBarController?.tabBar.isHidden = false
        }
        if let dest = segue.destination as? RestaurantListController {
            dest.tabBarController?.tabBar.isHidden = false
        }
    }
    
    /**
     * View-related functions
     */
    
    // Hide nagivation bar when scrolling
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 0 {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }
    
}

//SCROLL IMPLEMENTATION
extension DiscoverPageViewController: ScrollDelegate {
    func didScroll() {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    func reachTop() {
    }
}

extension DiscoverPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
