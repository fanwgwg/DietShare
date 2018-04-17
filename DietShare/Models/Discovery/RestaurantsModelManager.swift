//
//  RestaurantsModelManager.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation
import BTree
import CoreLocation

/**
 * A RestaurantsModelManager contains all the restaurant-related model objects and act as a facade to other objects using
 * these models.
 */
class RestaurantsModelManager<T: ReadOnlyRestaurant> {
    private var restaurants: SortedSet<T>
    private var restaurantsDataSource: RestaurantsDataSource
    
    init() {
        print("restaurant init called")
        self.restaurantsDataSource = RestaurantsLocalDataSource.shared
        self.restaurants = restaurantsDataSource.getAllRestaurants() as! SortedSet<T>
    }
    
    func getAllRestaurants() -> SortedSet<T> {
        return self.restaurants
    }
    
    func getSortedRestaurantList(_ sorting: Sorting, _ typeFilters: Set<RestaurantType>, _ currentLocation: CLLocation?) -> [T] {
        var restaurantList = [T]()
        restaurantList.append(contentsOf: self.restaurants)
        if !typeFilters.isEmpty {
            restaurantList = restaurantList.filter { $0.getTypesAsEnum().overLapsWith(typeFilters)}
        }
        switch sorting {
        case .byRating:
            restaurantList.sort(by: {$0.getRatingScore() > $1.getRatingScore()})
            break
        case .byDistance:
            restaurantList.sort(by: {$0.getDistanceToLocation(currentLocation) < $1.getDistanceToLocation(currentLocation)})
        }
        return restaurantList
    }
    
    func getRestaurantFromID(_ ID: String) -> Restaurant? {
        return self.restaurantsDataSource.getRestaurantByID(ID)
    }
    
    func getNumOfRestaurants() -> Int {
        return self.restaurantsDataSource.getNumOfRestaurants()
    }
    
    // Obtain a list of restaurants to be displayed in Discover Page
    func getDisplayedList(_ numOfItem: Int) -> [T] {
        var displayedList = [T]()
        var count = 0
        for restaurant in self.restaurants {
            if (count >= numOfItem) {
                break
            }
            displayedList.append(restaurant)
            count += 1
        }
        return displayedList
    }
    
    
    func addRating(_ restaurant: Restaurant, _ rating: Rating) {
        restaurant.addRating(rating)
        self.restaurantsDataSource.updateRestaurant(restaurant.getID(), restaurant)
    }
    
    func addPost(_ restaurant: Restaurant, _ post: Post) {
        restaurant.addPost(post)
        self.restaurantsDataSource.updateRestaurant(restaurant.getID(), restaurant)
    }
}

extension Set where Element == RestaurantType {
    func overLapsWith(_ anotherArray: Set<RestaurantType>) -> Bool {
        for element in self {
            if anotherArray.contains(element) {
                return true
            }
        }
        return false
    }
}
