//
//  NotesListMapViewController.swift
//  Everpobre
//
//  Created by Aitor Garcia on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import MapKit

class NotesListMapViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    let notebook: Notebook
    let coredataStack: CoreDataStack
    
    var notes: [Note] = [] {
        didSet {
            updateAnnotations()
        }
    }
    
    // MARK: - Init
    
    init(notebook: Notebook, coredataStack: CoreDataStack) {
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.coredataStack = coredataStack
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Map"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        updateAnnotations()
    }
    
    func update(with notes: [Note]) {
        self.notes = notes
    }
    
    private func updateAnnotations() {
        var annotations: [MKPointAnnotation] = []
        for note in notes {
            if note.location != nil {
                let annotation = NoteAnnotation(with: note)   
                annotations.append(annotation)
            }
        }
        
        if let mapView = mapView, annotations.count > 0 {
            mapView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            mapView.showAnnotations(annotations, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate

extension NotesListMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? NoteAnnotation {
            let note = annotation.note
            let noteDetailVC = NoteDetailsViewController(kind: .existing(note: note), managedContext: coredataStack.managedContext)
            noteDetailVC.delegate = tabBarController as! NotesListTabBarController
            self.navigationController?.pushViewController(noteDetailVC, animated: true)
        }
    }
}

