//
//  NoteAnnotation.swift
//  Everpobre
//
//  Created by Aitor Garcia on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation
import MapKit

class NoteAnnotation: MKPointAnnotation {
    
    var note: Note
    
    init(with note: Note) {
        self.note = note
        
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(latitude: note.location!.latitude, longitude: note.location!.longitude)
        self.title = note.title
    }
}
