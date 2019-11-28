//
//  DailyDozenViewModel.swift
//  DailyDozen
//
//  Created by marc on 2019.11.26.
//  Copyright © 2019 Nutritionfacts.org. All rights reserved.
//

import Foundation

class DailyDozenViewModel {
    
    static let rowTypeArray: [DataCountType] = [
        .dozeBeans,
        .dozeBerries,
        .dozeFruitsOther,
        .dozeVegetablesCruciferous,
        .dozeGreens,
        .dozeVegetablesOther,
        .dozeFlaxseeds,
        .dozeNuts,
        .dozeSpices,
        .dozeWholeGrains,
        .dozeBeverages,
        .dozeExercise,
        .otherVitaminB12
    ]
        
    // MARK: - Properties
    private let tracker: DailyTracker
    
    /// Returns Daily Dozen item count.
    var count: Int {
        return DailyDozenViewModel.rowTypeArray.count
    }

    var trackerDate: Date {
        tracker.date
    }
    
    // MARK: - Inits
    init(tracker: DailyTracker) {
        self.tracker = tracker
    }
    
    // MARK: - Methods
    /// Returns an item name and type in the doze for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: A tuple with the item heading, image name and supplemental flag.
    func itemInfo(rowIndex: Int) -> (itemType: DataCountType, isSupplemental: Bool) {
        let rowType: DataCountType = DailyDozenViewModel.rowTypeArray[rowIndex]
        let heading = rowType.headingDisplay
        let isSupplemental = heading.contains("Vitamin")
            || heading.contains("Omega")
        
        return (rowType, isSupplemental)
    }
    
    /// Returns an item streak count for the current index.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The streak count.
    /// :!!!: replaces itemStreak(for index: Int) -> Int
    func itemStreak(rowIndex: Int) -> Int {
        let itemType = DailyDozenViewModel.rowTypeArray[rowIndex]
        if let dataCountRecord = tracker.itemsDict[itemType] {
            return dataCountRecord.streak
        } else {
            return 0
        }
    }
    
    /// Returns a url for the current item name.
    ///
    /// - Parameter itemName: The item name.
    /// - Returns: A NutritionFacts topic url.
    func topicURL(itemTypeKey: String) -> URL {
        let topic = TextsProvider.shared.getTopic(itemTypeKey: itemTypeKey)
        return LinksService.shared.link(forTopic: topic)
    }
    
    /// Returns item states in the doze for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The states booland array.
    func itemStates(rowIndex: Int) -> [Bool] {
        let rowType = DailyDozenViewModel.rowTypeArray[rowIndex]
        let maxServings = rowType.maxServings
        var states = [Bool](repeating: false, count: maxServings)
        if let count = tracker.itemsDict[rowType]?.count {
            for i in 0..<count {
                states[i] = true
            }
        }
        return states
    }
    
    /// Returns an item type type in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item DataCountType.
    func itemType(rowIndex: Int) -> DataCountType {
        return DailyDozenViewModel.rowTypeArray[rowIndex]
    }
    
    /// Returns an item type key in the tracker for the current index.
    ///
    /// - Parameter index: The current row index.
    /// - Returns: The item type key string.
    func itemTypeKey(rowIndex: Int) -> String {
        return DailyDozenViewModel.rowTypeArray[rowIndex].typeKey
    }

    func itemPid(rowIndex: Int) -> String {
        let itemType = DailyDozenViewModel.rowTypeArray[rowIndex]
        return tracker.getPid(typeKey: itemType)
    }

    /// Returns an image name for the current index.
    ///
    /// - Parameter index: The current table row index.
    /// - Returns: The image name.
    func imageName(rowIndex: Int) -> String {
        return DailyDozenViewModel.rowTypeArray[rowIndex].imageName
    }
    
}