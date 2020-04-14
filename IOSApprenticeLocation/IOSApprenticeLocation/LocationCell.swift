//
//  LocationCell.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/13/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//

import UIKit


class LocationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    
    func configure(for location : Location)   {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = String(format:"Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
    }
}
