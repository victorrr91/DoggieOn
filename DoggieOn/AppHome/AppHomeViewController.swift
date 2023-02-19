//
//  AppHomeViewController.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/08.
//

import Foundation
import UIKit

final class AppHomeViewController: UIViewController {

    private var dogs = [Dog]()
    private var currentPage: Int = 0
    private var favouriteDict = [String: Int]()

    var network: DogNetworkProtocol

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlCalled), for: .valueChanged)
        return refreshControl
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        let width = (view.frame.width - 48) / 2
        layout.itemSize = CGSize(width: width, height: 180)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(
            DogsListViewCell.self,
            forCellWithReuseIdentifier: DogsListViewCell.identifier
        )

        collectionView.register(
            CollectionViewFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "FooterView"
        )

        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.refreshControl = refreshControl

        return collectionView
    }() //CollectionView

    //MARK: Bottom indicator when data loading
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
                    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
                    footer.addSubview(bottomIndicator)

                    return footer
                }
                return UICollectionReusableView()
    }

    class CollectionViewFooterView: UICollectionReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    private lazy var bottomIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
        return indicator
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.network = DogNetworkAPI()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        requestDogs()
        requestFavourites()

    }

    private func setupViews() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension AppHomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DogsListViewCell.identifier,
            for: indexPath
        ) as? DogsListViewCell else { return UICollectionViewCell() }

        if !dogs.isEmpty,
           !favouriteDict.isEmpty {
            let dog = dogs[indexPath.row]

            cell.configureCell(
                data: dog,
                tag: indexPath.row,
                delegate: self,
                isFavourite: checkIsFavourite(dog: dog)
            )
        }

        return cell
    }

    private func checkIsFavourite(dog: Dog) -> Bool {
        if let dogId = dog.id,
           favouriteDict.keys.contains(dogId) {
            return true
        }
        return false
    }
}

extension AppHomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentIndex = indexPath.row
        if currentIndex % 20 == 17,
           currentIndex / 20 == (currentPage - 1) {
            requestDogs()
            self.bottomIndicator.startAnimating()
        }
    }
}

extension AppHomeViewController: LikeButtonDelegate {
    
    func isLike(_ sender: UIButton) {
        if let dogId = dogs[sender.tag].id {
            network.postFavourite(imageId: dogId) { result in
                switch result {
                case .success(let response):
                    self.favouriteDict[dogId] = response.id
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func isUnlike(_ sender: UIButton) {
        if let dogId = dogs[sender.tag].id,
           let favouriteId = favouriteDict[dogId] {
            network.deleteFavourites(favouriteId: favouriteId)
        }
    }
}

// Actions
private extension AppHomeViewController {

    @objc func refreshControlCalled() {
        currentPage = 0
        dogs = []
        requestDogs()
    }

    func requestDogs() {
        self.network.fetchDogs(page: currentPage) { [weak self] result in
            switch result {
            case .success(let dogs):
                DispatchQueue.main.async {
                    self?.dogs += dogs
                    self?.currentPage += 1
                    self?.collectionView.reloadData()
                    self?.refreshControl.endRefreshing()
                    self?.bottomIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func requestFavourites() {
        network.fetchFavourites { [weak self] result in
            switch result {
            case .success(let favourites):
                favourites.forEach { favourite in
                    if let imageId = favourite.imageID {
                        self?.favouriteDict[imageId] = favourite.id
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
