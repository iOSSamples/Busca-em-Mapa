//
//  POIAnnotation.swift
//  Busca Mapa
//
//  Created by Juliana Chahoud on 10/20/14.
//  Copyright (c) 2014 FIAP. All rights reserved.
//

import UIKit
import MapKit

class POIAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var mapItem: MKMapItem
    var imageName = UIImage(named: "poi")
    
    init(coordinate: CLLocationCoordinate2D,
              title: String,
           subtitle: String,
            mapItem: MKMapItem) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.mapItem = mapItem
                
    }
    
}
