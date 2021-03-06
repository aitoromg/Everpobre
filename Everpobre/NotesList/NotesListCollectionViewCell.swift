//
//  NotesListCollectionViewCell.swift
//  Everpobre
//
//  Created by Charles Moncada on 11/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

class NotesListCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
	var item: Note!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	func configure(with item: Note) {
		backgroundColor = .white
		titleLabel.text = item.title
		creationDateLabel.text = (item.creationDate as Date?)?.customStringLabel()
        if let imageData = item.image, imageData.length > 0 {
            imageView.image = UIImage(data: imageData as Data)
        }
	}
}
