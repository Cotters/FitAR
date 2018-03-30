//
//  Extensions.swift
//  FitnessApp
//
//  Created by Josh Cotterell on 24/11/2017.
//  Copyright © 2017 Josh Cotterell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// MARK: Sign In extensions
extension UINavigationController {
    public func presentLoginScreen() {
        // Show login/register pages
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        present(ScrollViewController(collectionViewLayout: layout), animated: true, completion: nil)
    }
}

// Removes unnecessary divisors and alpha parameter
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
    
    static let lightGrey = UIColor(r: 200, g: 200, b: 200)
    static let darkBackground = UIColor(r: 50, g: 55, b: 55)
    static let systemBlue = UIColor(r: 29, g: 155, b: 246)
    static let darkSystemBlue = UIColor(r: 6, g: 120, b: 200)
    static let errorRed = UIColor(r: 255, g: 50, b: 50)
}
// MARK: - Anchors
// Helps anchor things to superviews
extension UIView {
    
    public func anchorCenterXToSuperview(withWidth width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: 0).isActive = true
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    public func anchorCenterYToSuperview(withHeight height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: 0).isActive = true
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    public func anchorCenterSuperview() {
        anchorCenterXToSuperview(withWidth: 0)
        anchorCenterYToSuperview(withHeight: 0)
    }
    
    public func anchorCenterSuperview(withWidth width: CGFloat, withHeight height: CGFloat) {
        anchorCenterXToSuperview(withWidth: width)
        anchorCenterYToSuperview(withHeight: height)
    }
    
    public func centerInView(view: UIView) {
        addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
    }
    
    public func anchor(_ top: NSLayoutYAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat, bottomConstant: CGFloat, leftConstant: CGFloat, rightConstant: CGFloat, width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: rightConstant))
        }
        
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
//        anchors.forEach({$0.isActive = true})
        NSLayoutConstraint.activate(anchors)
        
        _ = anchors
    }    
}

// MARK: - Alerts
extension UIViewController {
    public func showAlert(withTitle title: String, message: String, actions: [UIAlertAction], style: UIAlertControllerStyle) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    public func showMessage(withTitle: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    public func showSettingsAlert(withMessage message: String, and url: URL?) {
        let actions = [UIAlertAction(title: "Settings", style: .default, handler: { _ in
            DispatchQueue.main.async {
                if let settingsURL = url {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            
        })]
        showAlert(withTitle: "Error", message: message, actions: actions, style: .alert)
    }
}


// MARK: - TextFields
extension UITextField {
    func customTextField(backgroundColor: UIColor, placeholder: String, keyboardType: UIKeyboardType?, isSecureTextEntry: Bool?) -> UITextField {
        let tf = UITextField()
        tf.backgroundColor = backgroundColor
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType != nil ? keyboardType! : UIKeyboardType.default
        tf.isSecureTextEntry = isSecureTextEntry != nil ? isSecureTextEntry! : false
        return tf
    }
}


// MARK: - Location Extensions

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}

extension Int {
    /// Converts a Double to a string representing the time of that Double.
    var timeString: String {
        let (h,m,s) = ((self / 3600), (self % 3600) / 60, (self % 60))
        if h >= 1 {
            return "\(h) hour, \(m)minutes and \(s)s"
        } else if m >= 1 {
            return "\(m) minutes \(s)s"
        } else {
            return "\(s) seconds"
        }
    }
}

let metersPerRadianLat: Double = 6373000.0
let metersPerRadianLon: Double = 5602900.0

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let b = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians()) * cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees()
    }

    func coordinate(with bearing: Double, and distance: Double) -> CLLocationCoordinate2D {
        
        let distRadiansLat = distance / metersPerRadianLat  // earth radius in meters latitude
        let distRadiansLong = distance / metersPerRadianLon // earth radius in meters longitude
        
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
    
    static func getIntermediaryLocations(currentLocation: CLLocation, destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var distances = [CLLocationCoordinate2D]()
        let metersIntervalPerNode: Float = 10
        var distance = Float(destinationLocation.distance(from: currentLocation))
        let bearing = currentLocation.coordinate.calculateBearing(to: destinationLocation.coordinate)
        while distance > 10 {
            distance -= metersIntervalPerNode
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            if !distances.contains(newLocation) {
                distances.append(newLocation)
            }
        }
        return distances
    }
}

///Translation in meters between 2 locations
public struct LocationTranslation {
    public var latitudeTranslation: Double
    public var longitudeTranslation: Double
    public var altitudeTranslation: Double
    
    public init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}

public extension CLLocation {
    public convenience init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) {
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    
    ///Translates distance in meters between two locations.
    ///Returns the result as the distance in latitude and distance in longitude.
    public func translation(toLocation location: CLLocation) -> LocationTranslation {
        let inbetweenLocation = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let distanceLatitude = location.distance(from: inbetweenLocation)
        
        let latitudeTranslation: Double
        
        if location.coordinate.latitude > inbetweenLocation.coordinate.latitude {
            latitudeTranslation = distanceLatitude
        } else {
            latitudeTranslation = 0 - distanceLatitude
        }
        
        let distanceLongitude = self.distance(from: inbetweenLocation)
        
        let longitudeTranslation: Double
        
        if self.coordinate.longitude > inbetweenLocation.coordinate.longitude {
            longitudeTranslation = 0 - distanceLongitude
        } else {
            longitudeTranslation = distanceLongitude
        }
        
        let altitudeTranslation = location.altitude - self.altitude
        
        return LocationTranslation(
            latitudeTranslation: latitudeTranslation,
            longitudeTranslation: longitudeTranslation,
            altitudeTranslation: altitudeTranslation)
    }
    
    public func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        return annotation
    }
}

extension MKMapView {
    public func clear() {
        self.removeAnnotations(self.annotations)
        self.removeOverlays(self.overlays)
    }
}

extension MKPointAnnotation {
    /// Retrieves the latitude and longitude values as a CLLocation object.
    public func getLocation() -> CLLocation {
        return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
    
    /// Returns the distance between two MKPointAnnotations.
    public func getDistance(to destination: MKPointAnnotation) -> Double {
        return self.getLocation().distance(from: destination.getLocation())
    }
}
