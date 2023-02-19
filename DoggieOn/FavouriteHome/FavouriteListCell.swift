//
//  FavouriteListCell.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/10.
//

import Foundation
import UIKit
import Kingfisher

protocol DeleteFavouriteDelegate {
    func presentDeleteAlert(index: Int)
}

final class FavouriteListCell: UICollectionViewCell {

    static let identifier = "FavouriteListCell"

    var delegate: DeleteFavouriteDelegate?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.isSelected = true
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc
    private func likeButtonTapped() {
        delegate?.presentDeleteAlert(index: self.tag)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(
        dog: Favourite,
        tag: Int,
        delegate: DeleteFavouriteDelegate
    ) {
        self.setImage(dog)
        self.tag = tag
        self.delegate = delegate
    }

    private func setImage(_ dog: Favourite) {
        if let url = dog.image?.url,
           let imageUrl = URL(string: url) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageUrl,
                options: [
                    .transition(.fade(1))
                ]
            )
        }
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(likeButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            likeButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
