//
//  FavouriteHomeViewController.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/10.
//

import UIKit

class FavouriteHomeViewController: UIViewController {

    private var favourites = [Favourite]()

    var network: DogNetworkProtocol

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        let width = (view.frame.width - 48)
        layout.itemSize = CGSize(width: width, height: 250)
        layout.minimumLineSpacing = 20

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            FavouriteListCell.self,
            forCellWithReuseIdentifier: FavouriteListCell.identifier
        )
        collectionView.dataSource = self

        return collectionView
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        requestFavourites()
    }

    private func setupViews() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension FavouriteHomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favourites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavouriteListCell.identifier,
            for: indexPath
        ) as? FavouriteListCell else { return UICollectionViewCell() }

        if !favourites.isEmpty {
            let dog = favourites[indexPath.row]

            cell.configureCell(
                dog: dog,
                tag: indexPath.row,
                delegate: self
            )
        }
        return cell
    }
}

extension FavouriteHomeViewController: DeleteFavouriteDelegate {

    func presentDeleteAlert(index: Int) {
        let alertController = UIAlertController(title: "삭제", message: "즐겨찾기에서 정말 삭제하시겠습니까?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let delete = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            let deletedDog = self?.favourites[index]
            guard let dogId = deletedDog?.id else { return }
            self?.favourites.remove(at: index)
            self?.deleteFavourites(id: dogId)
        }
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.present(alertController, animated: false)
    }
}

private extension FavouriteHomeViewController {

    func requestFavourites() {
        network.fetchFavourites { [weak self] result in
            switch result {
            case .success(let favourites):
                self?.favourites = favourites
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
        }
    }

    func deleteFavourites(id: Int) {
        network.deleteFavourites(favouriteId: id)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
