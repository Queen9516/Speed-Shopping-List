//
//  ImageModel.swift
//  Speed Shopping List
//
//  Created by Wang on 11/30/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation

class ImageModel {
    
    var itemImage: String
    
    init(dataDictionary:Dictionary<String,String>) {
        itemImage = dataDictionary["itemImage"]!
    }
    
    class func newGalleryItem(_ dataDictionary:Dictionary<String,String>) -> ImageModel {
        return ImageModel(dataDictionary: dataDictionary)
    }
    
}
