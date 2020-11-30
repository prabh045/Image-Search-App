//
//  ViewController.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 26/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Properties
    let searchController = UISearchController(searchResultsController: nil)
    let sectionInsets = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    var itemsPerRow: CGFloat = 3 {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    lazy var searchBar = UISearchBar(frame: .zero)
    lazy var optionButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Options"
        button.target = self
        button.action = #selector(showImageOptions)
        return button
    }()
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var flickrViewModel = FlickrPhotoViewModel()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupConstraints()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //searchBar.becomeFirstResponder()
    }
    
    //MARK: SetUp
    func setupSearchBar() {
        searchBar.placeholder = "Search Photos"
        searchBar.showsSearchResultsButton = true
        searchBar.delegate = self
        navigationItem.rightBarButtonItem = optionButton
        navigationItem.titleView = searchBar
    }
    
    func setupCollectionView(){
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.backgroundColor = .white
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        self.view.addSubview(imageCollectionView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    func setupViewModel() {
        flickrViewModel.photosCount.bind { [weak self] (_) in
            DispatchQueue.main.async {
                 self?.imageCollectionView.reloadData()
            }
        }
//        flickrViewModel.photoState.bind { [weak self] (state) in
//            DispatchQueue.main.async {
//                if state == .downloaded {
//                    self?.imageCollectionView.reloadData()
//                }
//            }
//        }
//        flickrViewModel.photoDetails.bind { (photoDetails) in
//            let _ = photoDetails.enumerated().map { (index,photoDetail) in
//                photoDetail.state.bind { [weak self] (_) in
//                    let indexPath = IndexPath(item: index, section: 0)
//                    DispatchQueue.main.async {
//                        print("Reloading.......")
//                        self?.imageCollectionView.reloadData()
//                    }
//                }
//            }
//        }
        flickrViewModel.search()
    }
    
    //MARK: Action Methods
    @objc func showImageOptions() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        ActionSheet.showImageOptions(for: self) { [weak self] (alert) in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
}

//MARK: UISearchBarDelegate Delegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        flickrViewModel.search(text: searchBar.text ?? flickrViewModel.searchText)
    }
}

//MARK: CollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrViewModel.photoDetails.value.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath) as? ImageCollectionViewCell else {
            fatalError("Could not initialise ImageCollectionViewCell")
        }
        print("indexpath row is \(indexPath)")
      //  cell.imageView.image = flickrViewModel.getImageFor(indexPath: indexPath)
        let photoDeatilModel = flickrViewModel.photoDetails.value[indexPath.row]
       // cell.imageView.image = photoDeatilModel.image
        photoDeatilModel.state.bind { [weak cell] (_) in
            DispatchQueue.main.async {
                cell?.imageView.image = photoDeatilModel.image
            }
        }
        
        switch photoDeatilModel.state.value {
        case .new:
            print("new")
            flickrViewModel.downloadImageFor(photoDetails: photoDeatilModel, indexPath: indexPath)
        case .downloaded:
            print("downlaoded")
        case .failed:
            print("Failed")
        }
        
        return cell
    }
    
}

//MARK: CollectionView Delegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == flickrViewModel.photosCount.value - 1 && flickrViewModel.isInitialDataLoaded {
            if searchBar.text == "" {
                flickrViewModel.search()
            } else {
                flickrViewModel.search(text: searchBar.text ?? flickrViewModel.searchText)
            }
            print("need to append more")
        }
        flickrViewModel.increasePriorityForOperation(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("cell for indexPath \(indexPath) went beyond")
        flickrViewModel.decreasePriorityForOperation(at: indexPath)
    }
    

}




