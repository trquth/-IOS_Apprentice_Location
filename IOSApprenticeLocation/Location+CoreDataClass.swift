//
//  Location+CoreDataClass.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/12/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title : String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle : String? {
        return category
    }
}
