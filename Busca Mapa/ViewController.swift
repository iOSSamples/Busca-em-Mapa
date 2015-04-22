//
//  ViewController.swift
//  Busca Mapa
//
//  Created by Juliana Chahoud on 10/16/14.
//  Copyright (c) 2014 FIAP. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var fiapAnnotation: FIAPAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         locationManager.requestWhenInUseAuthorization()
        
        //cria um mapa com as coordenadas da FIAP
        let fiapLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(-23.573978,-46.623272)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(fiapLocation, 8000, 8000)
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        //criar um pin do parque do ibirapuera
        let ibiraAnnotation:MKPointAnnotation = MKPointAnnotation()
        ibiraAnnotation.coordinate = CLLocationCoordinate2DMake(-23.587416, -46.657634)
        ibiraAnnotation.title = "Parque do Ibirapuera"
        
        //criar um pin no metro vila mariana
        let vilaMarianaAnnotation:MKPointAnnotation = MKPointAnnotation()
        vilaMarianaAnnotation.coordinate = CLLocationCoordinate2DMake(-23.589541, -46.634701)
        vilaMarianaAnnotation.title = "Metrô Vila Mariana"
        vilaMarianaAnnotation.subtitle = "Estação da linha azul"

        //criar anotaçao customizada para a FIAP
        self.fiapAnnotation = FIAPAnnotation(coordinate: fiapLocation,
            title: "FIAP",
            subtitle: "http://www.fiap.com.br")
        
        self.mapView.addAnnotations([ibiraAnnotation, vilaMarianaAnnotation, fiapAnnotation])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeMapType (sender: UISegmentedControl) {
        
        //changes the mapView Type
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.mapView.mapType = MKMapType.Standard
            
        case 1:
            self.mapView.mapType = MKMapType.Satellite
            
        case 2:
            self.mapView.mapType = MKMapType.Hybrid
            
        default:
            println("other value")
            
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is FIAPAnnotation{
        
            //verificar se a marcação já existe para tentar reutilizá-la
            let reuseId = "fiapAnnot"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)

            //se a view não existir
            if anView == nil {
                //criar a view como subclasse de MKAnnotationView
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                
                //trocar a imagem pelo logo da FIAP
                anView.image = UIImage(named:"fiapLogo")
                
                //permitir que mostre o "balão" com informações da marcação
                anView.canShowCallout = true
                
                //adiciona um botão do lado direito do balão para futuro 'tap'
                anView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            }
            return anView
        }
        else if annotation is POIAnnotation{
            
            //verificar se a marcação já existe para tentar reutilizá-la
            let reuseId = "poiAnnot"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            
            //se a view não existir
            if anView == nil {
                //criar a view como subclasse de MKAnnotationView
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                
                anView.image = (annotation as POIAnnotation).imageName
                
                //permitir que mostre o "balão" com informações da marcação
                anView.canShowCallout = true
                
                //adiciona um botão do lado direito do balão para futuro 'tap'
                anView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            }
            return anView
        }
        
        return nil
    }
    

    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        if view.annotation is FIAPAnnotation
        {
            //quando o usuário selecionar o balão, abrir o site da FIAP
            let url:NSURL = NSURL(string: "http://www.fiap.com.br")!
            UIApplication.sharedApplication().openURL(url)
        }
        else if view.annotation is POIAnnotation
        {
            
            self.displayRegionCenteredOnMapItem((view.annotation as POIAnnotation).mapItem)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        
        //inicia um request com o texto digitado  with the text typed on the search bar and with current map region
        var request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.mapView.region
        
        //instancia uma busca em mapa com o request criado
        var search:MKLocalSearch = MKLocalSearch(request: request)
        
        //inicia um activity indicator
        var loading = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loading.center = self.view.center
        self.view.addSubview(loading)
        loading.startAnimating()
        
        //inicia a busca
        search.startWithCompletionHandler {
            (response:MKLocalSearchResponse!, error:NSError!) in
            if error==nil {
                
                //cria um array para guardar os resultados retornados
                var placemarks = NSMutableArray()
                for item:MKMapItem in response.mapItems as [MKMapItem] {
                    
                    //cria uma nova marcação por resultado
                    let place = POIAnnotation(coordinate: item.placemark.coordinate, title: item.name, subtitle: "", mapItem: item)
                    placemarks.addObject(place)
                }
                
                //limpa as annotations no mapa antes de adicionar as novas
                self.cleanAnnotations()
                self.mapView.addAnnotations(placemarks)
                
            }
            loading.stopAnimating()
            searchBar.resignFirstResponder()
            
        }
    }
    
    func cleanAnnotations(){
        
        //clean all the map annotations except fo the user and TDC Logo
        var anToremove = NSMutableArray(array: self.mapView.annotations)
        anToremove.removeObject(self.mapView.userLocation)
        anToremove.removeObject(self.fiapAnnotation)
        
        self.mapView.removeAnnotations(anToremove)
        
    }

    func displayRegionCenteredOnMapItem (from:MKMapItem){
        
        //Obtem a localizacao do item passado como parametro
        let fromLocation: CLLocation = from.placemark.location;
    
        let region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);

        
        let span = NSValue(MKCoordinateSpan:self.mapView.region.span)
        let opts = [
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan:region.span),
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: region.center)
        ]
        from.openInMapsWithLaunchOptions(opts)
        
        
    }

}

