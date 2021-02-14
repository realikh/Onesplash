//
//  FiltersViewModel.swift
//  Onesplash
//
//  Created by Мирас on 2/14/21.
//

import Foundation
import CoreData

final class FiltersViewModel {

    private(set) var data = [["Relevance", "Newest"],
                        ["Any", "Portrait", "Landscape", "Square"],
                        ["Any", "Black and White", "White", "Black",
                         "Yellow", "Orange", "Red", "Purple", "Magenta",
                         "Green", "Teal", "Blue"]]
    private(set) var headers = ["SORT BY", "ORIENTATION", "COLOR"]
    
}
