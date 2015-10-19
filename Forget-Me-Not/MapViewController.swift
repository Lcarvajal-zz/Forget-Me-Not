//
//  MapViewController.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 9/28/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let themeColor = UIColor.init(red: 0.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let locationManager = CLLocationManager()
    var pinDropped = Bool()
    var showedUserLocation = Bool()
    var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
    
    var notificationCircle = MKCircle()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showCurrentLocationButton: UIBarButtonItem!
    @IBOutlet weak var removePinButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        pinDropped = false
        removePinButton.enabled = false
        showedUserLocation = false
        self.mapView.delegate = self
        
        navigationController?.hidesBarsOnTap = true
        navigationController?.toolbarHidden = false
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Ask user for location authorization.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground.
        self.locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        // Put searchbar in navigation bar.
        searchBar.placeholder = "Search for place or address"
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.backgroundImage = UIImage();
        self.navigationItem.titleView = searchBar
        
        if !CLLocationManager.locationServicesEnabled() {
            // Display messaging prompting user to enable location services.
            let locationAlert = UIAlertController(title: "Error",
                message: "Enable location services in order to use Forget Me Not",
                preferredStyle: UIAlertControllerStyle.Alert)
            presentViewController(locationAlert, animated: true, completion: {})
        }
        
        // Register for notification types.
        let mySettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removePin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MapView
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !showedUserLocation {
            centerMapOnUserLocation()
            showedUserLocation = true
        }
    }
    
    func centerMapOnUserLocation() {
        // Set map center to user location.
        if mapView.region.span.latitudeDelta > 0.2
            && mapView.region.span.longitudeDelta > 0.2 {
                // Show current location with adjusted region on map.
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
        }
        else {
            // Just show current location.
            mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
        }
    }
    
    // Mark: - Pins
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            // Remove title of blue user location annotation.
            let tempAnnotation = annotation as! MKUserLocation
            tempAnnotation.title = nil
            return nil;
        }
        
        let identifier = "Pin"
        if annotation.isKindOfClass(MKAnnotation) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for annView in views{
            let endFrame = annView.frame
            annView.frame = CGRectOffset(endFrame, 0, -500)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                annView.frame = endFrame
            })
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = themeColor
            circle.fillColor = UIColor(red: 0.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            let circle = MKCircleRenderer(overlay: overlay)
            return circle
        }
    }
    
    @IBAction func dropPin(sender: UIGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Ended && !pinDropped {
            // Set new pin.
            let touchPoint = sender.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
        
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                // Show current pin on map.
                annotation.title = "Current Reminder"
                self.mapView.addAnnotation(annotation)
                let circle = MKCircle(centerCoordinate: annotation.coordinate, radius: 250 as CLLocationDistance)
                self.notificationCircle = circle
                self.mapView.addOverlay(circle)
                
                let circleRenderer = MKCircleRenderer(circle: circle)
                circleRenderer.invalidatePath()
                let mapPoint = MKMapPointForCoordinate(self.mapView.userLocation.coordinate)
                let circlePoint = circleRenderer.pointForMapPoint(mapPoint)
                let mapCoordinateIsInCircle = CGPathContainsPoint(circleRenderer.path, nil, circlePoint, false)
                if ( mapCoordinateIsInCircle ) {
                    self.performSegueWithIdentifier("userInRadius", sender: self)
                }
                
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.setToolbarHidden(false, animated: true)
                self.navigationController?.hidesBarsOnTap = false
            })
            
            pinDropped = true
            removePinButton.enabled = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showCurrentLocation(sender: AnyObject) {
        centerMapOnUserLocation()
    }
    
    func removePin() {
        // Remove old pin.
        mapView.removeAnnotations(mapView.annotations)
        pinDropped = false
        removePinButton.enabled = false
        
        // Remove circle overlay.
        mapView.removeOverlays(mapView.overlays)
    }
    
    @IBAction func removePin(sender: AnyObject) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = true
        removePin()
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userInRadius" {
            let navController = segue.destinationViewController
            let setInRadiusVC = navController.childViewControllers[0] as! SetInRadiusReminderViewController
            setInRadiusVC.notificationCircle = self.notificationCircle
        }
        else if segue.identifier == "userOutsideRadius" {
            
        }
    }

}