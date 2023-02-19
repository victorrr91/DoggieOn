//
//  DogsListViewCell.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/09.
//

import Foundation
import UIKit
import Kingfisher

protocol LikeButtonDelegate {
    func isLike(_ sender: UIButton)
    func isUnlike(_ sender: UIButton)
}

final class DogsListViewCell: UICollectionViewCell {
    static let identifier = "DogsListViewCell"

    var delegate: LikeButtonDelegate?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        likeButton.isSelected = false
    }

    func configureCell(
        data: Dog,
        tag: Int,
        delegate: LikeButtonDelegate,
        isFavourite: Bool
    ) {
        self.setImage(data)
        self.likeButton.tag = tag
        self.delegate = delegate
        self.likeButton.isSelected = isFavourite
    }

    private func setImage(_ data: Dog) {
        if let urlString = data.url,
           let imgUrl = URL(string: urlString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imgUrl,
                options: [
                    .transition(.fade(1))
                ]
            )
        }
    }

    @objc
    private func likeButtonTapped(_ sender: UIButton) {
        likeButton.isSelected = !likeButton.isSelected
        if likeButton.isSelected {
            delegate?.isLike(sender)
        } else {
            delegate?.isUnlike(sender)
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
