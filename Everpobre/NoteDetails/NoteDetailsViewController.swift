//
//  NoteDetailsViewController.swift
//  Everpobre
//
//  Created by Charles Moncada on 08/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var creationDateLabel: UILabel!
	@IBOutlet weak var lastSeenDateLabel: UILabel!
	@IBOutlet weak var descriptionTextView: UITextView!

//	let note: Note
	enum Kind {
		case new
		case existing(Note)
	}

	let kind: Kind

	init(kind: Kind) {
		self.kind = kind
		super.init(nibName: "NoteDetailsViewController", bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		configure(with: kind)
    }

	private func configure(with kind: Kind) {
		switch kind {
		case .new:
			let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save
				, target: self, action: #selector(saveNote))
			self.navigationItem.rightBarButtonItem = saveButtonItem
			let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
			navigationItem.leftBarButtonItem = cancelButtonItem
			configureValues()
		case .existing:
			configureValues()
		}
	}

	@objc private func saveNote() { }

	@objc private func cancel() {
		dismiss(animated: true, completion: nil)
	}

	private func configureValues() {
		title = kind.title
		titleTextField.text = kind.note?.text
		//tagsLabel.text = note.tags?.joined(separator: ",")
		creationDateLabel.text = "Creado: \((kind.note?.creationDate as Date?)?.customStringLabel() ?? "ND")"
		lastSeenDateLabel.text = "Visto: \((kind.note?.lastSeenDate as Date?)?.customStringLabel() ?? "ND")"
		descriptionTextView.text = kind.note?.text ?? "Ingrese texto..."
	}

}

private extension NoteDetailsViewController.Kind {
	var note: Note? {
		guard case let .existing(note) = self else { return nil }
		return note
	}

	var title: String {
		switch self {
		case .existing:
			return "Detalle"
		case .new:
			return "Nueva Nota"
		}
	}
}
