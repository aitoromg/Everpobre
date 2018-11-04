//
//  NotesListTabBarController.swift
//  Everpobre
//
//  Created by Aitor Garcia on 04/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import CoreData

class NotesListTabBarController: UITabBarController {

    let notebook: Notebook
    let coredataStack: CoreDataStack
    var newNoteListVC: NewNotesListViewController?
    var noteListMapVC: NotesListMapViewController?
    var notes: [Note] = [] {
        didSet {
            newNoteListVC?.update(with: notes)
            noteListMapVC?.update(with: notes)
        }
    }
    
    // MARK: - Init
    
    init(notebook: Notebook, coredataStack: CoreDataStack) {
        self.notebook = notebook
        self.coredataStack = coredataStack
        super.init(nibName: nil, bundle: nil)
        
        title = "Notes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Core Data
    
    func getFetchedResultsController(with predicate: NSPredicate) -> NSFetchedResultsController<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(Note.title), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: coredataStack.managedContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newNoteListVC = NewNotesListViewController(notebook: notebook, coredataStack: coredataStack)
        noteListMapVC = NotesListMapViewController(notebook: notebook, coredataStack: coredataStack)
        
        viewControllers = [
            newNoteListVC!,
            noteListMapVC!
        ]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    // MARK: - Helper methods
    
    @objc private func addNote() {
        let newNoteVC = NoteDetailsViewController(kind: .new(notebook: notebook), managedContext: coredataStack.managedContext)
        newNoteVC.delegate = self
        let navVC = UINavigationController(rootViewController: newNoteVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc private func exportCSVDeprecated() {
        
        coredataStack.storeContainer.performBackgroundTask { [unowned self] context in
            
            var results: [Note] = []
            
            do {
                results = try self.coredataStack.managedContext.fetch(self.notesFetchRequest(from: self.notebook))
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
            let exportPath = NSTemporaryDirectory() + "export.csv"
            let exportURL = URL(fileURLWithPath: exportPath)
            FileManager.default.createFile(atPath: exportPath, contents: Data(), attributes: nil)
            
            let fileHandle: FileHandle?
            do {
                fileHandle = try FileHandle(forWritingTo: exportURL)
            } catch let error as NSError {
                print(error.localizedDescription)
                fileHandle = nil
            }
            
            if let fileHandle = fileHandle {
                for note in results {
                    fileHandle.seekToEndOfFile()
                    guard let csvData = note.csv().data(using: .utf8, allowLossyConversion: false) else { return }
                    fileHandle.write(csvData)
                }
                
                fileHandle.closeFile()
                DispatchQueue.main.async { [weak self] in
                    self?.showExportFinishedAlert(exportPath)
                }
                
            } else {
                print("no podemos exportar la data")
            }
        }
        
    }
    
    @objc private func exportCSV() {
        var results: [Note] = []
        do {
            results = try self.coredataStack.managedContext.fetch(getFetchedResultsController(with: NSPredicate(format: "notebook == %@", notebook)).fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        var csv = ""
        for note in results {
            csv = "\(csv)\(note.csv())\n"
        }
        
        let activityView = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        self.present(activityView, animated: true)
    }
    
    private func showExportFinishedAlert(_ exportPath: String) {
        let message = "El archivo CSV se encuentra en \(exportPath)"
        let alertController = UIAlertController(title: "Exportacion terminada", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    private func notesFetchRequest(from notebook: Notebook) -> NSFetchRequest<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        //fetchRequest.fetchBatchSize = 50
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return fetchRequest
    }
}

// MARK: - NoteDetailsViewControllerDelegate

extension NotesListTabBarController: NoteDetailsViewControllerProtocol {
    func didSaveNote() {
        self.notes = (notebook.notes?.array as? [Note]) ?? []
    }
}
