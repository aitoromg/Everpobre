//
//  Notebook+CoreDataClass.swift
//  Everpobre
//
//  Created by Charles Moncada on 09/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Notebook)
public class Notebook: NSManagedObject {

}

extension Notebook {
    func csv() -> String {
        let exportedName = name ?? "Name"
        let exportedCreationDate = (creationDate as Date?)?.customStringLabel() ?? "ND"
        
        var exportedNotes = ""
        if let notes = notes {
            for note in notes {
                if let note = note as? Note {
                    exportedNotes = "\(exportedNotes)\(note.csv())\n"
                }
            }
        }
        
        return "\(exportedCreationDate),\(exportedName)\n\(exportedNotes)"
    }
}
