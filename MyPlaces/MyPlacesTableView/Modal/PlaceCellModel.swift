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
    
    convenience init(title: String, type: String?, location: String?, imageData: Data?) {
        self.init()
        self.title = title
        self.type = type
        self.location = location
        self.imageData = imageData 
    }
}
