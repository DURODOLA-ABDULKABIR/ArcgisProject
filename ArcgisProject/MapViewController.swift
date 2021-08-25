//
//  ViewController.swift
//  ArcgisProject
//
//  Created by Decagon on 20.8.21.
//

import UIKit
import ArcGIS

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    private let graphicsOverlay = AGSGraphicsOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        setupUI()
        setupGraphicsOverlay()
        //        addGraphics()
    }
    
    private func setUpMap() {
        //MARK:- display an offline map.
        let map = AGSMap(
            item: AGSPortalItem(
                portal: AGSPortal.arcGISOnline(withLoginRequired: false),
                itemID: "5a030a31e42841a89914bd7c5ecf4d8f"
            )
        )
        mapView.map = map
        
        //        let portal = AGSPortal.arcGISOnline(withLoginRequired: false)
        //        let itemID = "41281c51f9de45edaf1c8ed44bb10e30"
        //        let portalItem = AGSPortalItem(portal: portal, itemID: itemID)
        //        let map = AGSMap(item: portalItem)
        //        mapView.map = map
        
        //MARK:- display a web map
        //        let map = AGSMap(basemapStyle: .arcGISTopographic)
        //        mapView.map = map
        //        mapView.setViewpoint(
        //            AGSViewpoint(
        //                latitude: 34.02700,
        //                longitude: -118.80500,
        //                scale: 72_000
        //            )
        //        )
    }
    
    @objc func userSelectedDownloadOfflineMap(_ sender: UIBarButtonItem) {
        guard let offlineArea = mapView.visibleArea else { return }
        sender.isEnabled = false
        addGraphic(for: offlineArea)
        mapView.setViewpointGeometry(offlineArea, padding: 25)
        downloadOfflineMap(with: offlineArea, at: temporaryDirectoryURL)
        
    }
    
    private var temporaryDirectoryURL: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(ProcessInfo().globallyUniqueString)
    }
    
    private var offlineMapTask: AGSOfflineMapTask?
    private var offlineMapJob: AGSGenerateOfflineMapJob?
    
    private func downloadOfflineMap(with offlineArea: AGSGeometry, at downloadDirectory: URL) {
        guard let map = mapView.map else { return }
        offlineMapTask = AGSOfflineMapTask(onlineMap: map)
        
        offlineMapTask?.defaultGenerateOfflineMapParameters(withAreaOfInterest: offlineArea) { [weak self] parameters, error in
            guard let self = self else { return }
            guard let offlineMapTask = self.offlineMapTask else { return }
            
            if let parameters = parameters {
                parameters.updateMode = .noUpdates
                parameters.esriVectorTilesDownloadOption = .useReducedFontsService
                let job = offlineMapTask.generateOfflineMapJob(with: parameters, downloadDirectory: downloadDirectory)
                (self.navigationItem.titleView as! UIProgressView).observedProgress = job.progress
                var n = 0
                job.start(statusHandler: { _ in
                    while n < job.messages.count {
                        print("Job message \(n): \(job.messages[n].message)")
                        n += 1
                    }
                }, completion: { [weak self] result, error in
                    guard let self = self else { return }
                    if let result = result {
                        self.mapView.map = result.offlineMap
                    } else if let error = error {
                        print("Error downloading the offline map: \(error)")
                        return
                    }
                })
                self.offlineMapJob = job
            } else if let error = error {
                print("Error fetching default parameters for the area of interest: \(error.localizedDescription)")
            }
            
        }
    }
    
    private func setupUI() {
        navigationItem.titleView = UIProgressView()
        navigationController?.isToolbarHidden = false
        let items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Download Map Area", style: .plain, target: self, action: #selector(userSelectedDownloadOfflineMap)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        setToolbarItems(items, animated: true)
        
    }
    
    private func setupGraphicsOverlay() {
        graphicsOverlay.renderer = AGSSimpleRenderer(
            symbol: AGSSimpleFillSymbol(
                style: .solid,
                color: .clear,
                outline: AGSSimpleLineSymbol(
                    style: .solid,
                    color: .red,
                    width: 3
                )
            )
        )
        mapView.graphicsOverlays.add(graphicsOverlay)
    }
    
    private func addGraphic(for offlineArea: AGSGeometry) {
        let graphic = AGSGraphic(geometry: offlineArea, symbol: nil)
        graphicsOverlay.graphics.add(graphic)
    }
    
    private func addGraphics() {
        
        //MARK:- Add a point graphic
        //        let graphicsOverlay = AGSGraphicsOverlay()
        //        mapView.graphicsOverlays.add(graphicsOverlay)
        //        let point = AGSPoint(x: -118.80657463861, y: 34.0005930608889, spatialReference: .wgs84())
        //        let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10.0)
        //        pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 2.0)
        //        let pointGrphic = AGSGraphic(geometry: point, symbol: pointSymbol)
        //        graphicsOverlay.graphics.add(pointGrphic)
        
        //MARK:- Add a line graphic
        //        let polyline = AGSPolyline(points:
        //                                    [
        //                                        AGSPoint(x: -118.821527826096, y: 34.0139576938577, spatialReference: .wgs84()),
        //                                        AGSPoint(x: -118.814893761649, y: 34.0080602407843, spatialReference: .wgs84()),
        //                                        AGSPoint(x: -118.808878330345, y: 34.0016642996246, spatialReference: .wgs84())
        //                                    ]
        //        )
        //        let polylineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 3.0)
        //        let polylineGraphic = AGSGraphic(geometry: polyline, symbol: polylineSymbol)
        //        graphicsOverlay.graphics.add(polylineGraphic)
        //
        //        //MARK:- Add a polygon graphic
        //        let polygon = AGSPolygon(points: [
        //            AGSPoint(x: -118.818984489994, y: 34.0137559967283, spatialReference: .wgs84()),
        //            AGSPoint(x: -118.806796597377, y: 34.0215816298725, spatialReference: .wgs84()),
        //            AGSPoint(x: -118.791432890735, y: 34.0163883241613, spatialReference: .wgs84()),
        //            AGSPoint(x: -118.79596686535, y: 34.008564864635, spatialReference: .wgs84()),
        //            AGSPoint(x: -118.808558110679, y: 34.0035027131376, spatialReference: .wgs84())
        //        ])
        //        let polygonSymbol = AGSSimpleFillSymbol(style: .solid, color: .orange, outline: AGSSimpleLineSymbol(style: .solid, color: .blue, width: 2.0))
        //        let polygonGraphics = AGSGraphic(geometry: polygon, symbol: polygonSymbol)
        //        graphicsOverlay.graphics.add(polygonGraphics)
    }
}

