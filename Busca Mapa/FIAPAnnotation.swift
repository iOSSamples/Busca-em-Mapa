//
//  FIAPAnnotation.swift
//  Busca Mapa
//
//  Created by Juliana Chahoud on 10/16/14.
//  Copyright (c) 2014 FIAP. All rights reserved.
//

import UIKit
import MapKit

class FIAPAnnotation: NSObject, MKAnnotation {
   
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}
