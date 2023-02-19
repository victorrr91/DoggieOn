//
//  UploadHomeViewController.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/11.
//

import Foundation
import UIKit
import PhotosUI

final class UploadHomeViewController: UIViewController {

    var network: DogNetworkProtocol

    private var selectedImage: UIImage? = nil

    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .systemIndigo

        return label
    }()

    private let uploadImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var imagePicker: PHPickerViewController = {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        return picker
    }()

    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("선택", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemPink
        button.addTarget(self, action: #selector(didTapSelectPhotoButton), for: .touchUpInside)
        return button
    }()

    private lazy var deletePhotoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapDeletePhotoButton), for: .touchUpInside)
        return button
    }()

    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("업로드", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)
        return button
    }()

    @objc
    private func didTapSelectPhotoButton() {
        present(imagePicker, animated: true)
    }

    @objc
    private func didTapDeletePhotoButton() {
        uploadImage.image = nil
        selectedImage = nil
        selectPhotoButton.setTitle("선택", for: .normal)
        deletePhotoButton.isHidden = true
    }

    @objc
    private func didTapUploadButton() {
        guard let image = selectedImage else { return }
        print(image)
        network.uploadImage(image: image) { result in
            switch result {
            case .success(let response):
                if response.approved == 1 {
                    self.uploadCompleteAlert()
                }

            case .failure(let error):
                print(error)
            }
        }
    }

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

        loadMyDogImage()
    }

    private func setupViews() {
        view.addSubview(userIdLabel)
        view.addSubview(uploadImage)
        view.addSubview(selectPhotoButton)
        view.addSubview(deletePhotoButton)
        view.addSubview(uploadButton)

        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            userIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            userIdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            uploadImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            uploadImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            uploadImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            uploadImage.heightAnchor.constraint(equalToConstant: view.frame.width - 48),

            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.topAnchor.constraint(equalTo: uploadImage.bottomAnchor, constant: 12),
            selectPhotoButton.widthAnchor.constraint(equalToConstant: 60),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 30),

            deletePhotoButton.topAnchor.constraint(equalTo: uploadImage.topAnchor, constant: 16),
            deletePhotoButton.trailingAnchor.constraint(equalTo: uploadImage.trailingAnchor, constant: -16),

            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            uploadButton.leadingAnchor.constraint(equalTo: uploadImage.leadingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: uploadImage.trailingAnchor),
            uploadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension UploadHomeViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let itemProvider = results.first?.itemProvider

        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.uploadImage.image = image as? UIImage
                    self.selectedImage = image as? UIImage
                    self.selectPhotoButton.setTitle("변경", for: .normal)
                    self.deletePhotoButton.isHidden = false
                }
            }
        } else {
            print("업로드할 사진을 선택해주세요.")
        }
    }
}

private extension UploadHomeViewController {

    func loadMyDogImage() {
        network.loadMyDogImage { [weak self] result in
            switch result {
            case .success(let dogs):
                let dog = dogs.first
                if let urlString = dog?.url,
                   let imgUrl = URL(string: urlString) {
                    DispatchQueue.main.async {
                        self?.userIdLabel.text = "\(dog?.subId ?? "")님의 반려견"
                        self?.uploadImage.kf.indicatorType = .activity
                        self?.uploadImage.kf.setImage(
                            with: imgUrl,
                            options: [
                                .transition(.fade(1))
                            ]
                        )
                    }
                }

            case .failure(let error):
                print(error)
            }
        }
    }

    func uploadCompleteAlert() {
        let alertController = UIAlertController(title: "업로드 완료", message: "당신의 사랑스러운 강아지 사진을 공유해줘서 감사합니다!", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(confirm)
        self.present(alertController, animated: false)
    }

}
