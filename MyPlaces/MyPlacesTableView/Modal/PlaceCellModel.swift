//
//  RestuarantCellModel.swift
//  MyPlaces
//
//  Created by Nikita Moskalenko on 6/3/20.
//  Copyright © 2020 Nikita Moskalenko. All rights reserved.
//

import  RealmSwift

final class PlaceCellModel: Object {
    @objc dynamic var title = ""
    @objc dynamic var type: String?
    @objc dynamic var location: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    convenience init(title: String, type: String?, location: String?, imageData: Data?, rating: Double) {
        self.init()
        self.title = title
        self.type = type
        self.location = location
        self.imageData = imageData
        self.rating = rating
    }
}
