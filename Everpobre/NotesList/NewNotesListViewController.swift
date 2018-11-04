//
//  NewNotesListViewController.swift
//  Everpobre
//
//  Created by Charles Moncada on 11/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import CoreData

class NewNotesListViewController: UIViewController {

	// MARK: IBOutlet
	@IBOutlet weak var collectionView: UICollectionView!

	// MARK: Properties

	let notebook: Notebook
	//let managedContext: NSManagedObjectContext
	let coredataStack: CoreDataStack!

	var notes: [Note] = [] {
		didSet {
			self.collectionView.reloadData()
		}
	}

	let transition = Animator()

	// MARK: Init

	init(notebook: Notebook, coredataStack: CoreDataStack) {
		self.notebook = notebook
		self.notes = (notebook.notes?.array as? [Note]) ?? []
		self.coredataStack = coredataStack
		super.init(nibName: "NewNotesListViewController", bundle: nil)
        
        title = "List"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Notes"
		self.view.backgroundColor = .white

		let nib = UINib(nibName: "NotesListCollectionViewCell", bundle: nil)
		collectionView.register(nib, forCellWithReuseIdentifier: "NotesListCollectionViewCell")

		collectionView.backgroundColor = .lightGray

        setupCollectionView()
	}
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }

	// MARK: Helper methods
    
    func update(with notes: [Note]) {
        self.notes = notes
    }

}

// MARK:- UICollectionViewDataSource

extension NewNotesListViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return notes.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesListCollectionViewCell", for: indexPath) as! NotesListCollectionViewCell
		cell.configure(with: notes[indexPath.row])
		return cell
	}

}

// MARK:- UICollectionViewDelegate

extension NewNotesListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailVC = NoteDetailsViewController(kind: .existing(note: notes[indexPath.row]), managedContext: coredataStack.managedContext)
		//detailVC.delegate = self
        detailVC.delegate = tabBarController as! NotesListTabBarController
		//self.show(detailVC, sender: nil)

		// custom animation
		let navVC = UINavigationController(rootViewController: detailVC)
		navVC.transitioningDelegate = self
		present(navVC, animated: true, completion: nil)

	}
}

// MARK:- UICollectionViewDelegateFlowLayout

extension NewNotesListViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 150)
	}
}

// MARK:- NoteDetailsViewControllerProtocol implementation

extension NewNotesListViewController: NoteDetailsViewControllerProtocol {
	func didSaveNote() {
		self.notes = (notebook.notes?.array as? [Note]) ?? []
	}
}

// MARK:- Custom Animation - UIViewControllerTransitioningDelegate

extension NewNotesListViewController: UIViewControllerTransitioningDelegate {

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let indexPath = (collectionView.indexPathsForSelectedItems?.first!)!
		let cell = collectionView.cellForItem(at: indexPath)
		transition.originFrame = cell!.superview!.convert(cell!.frame, to: nil)

		transition.presenting = true

		return transition
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return nil
	}
}
