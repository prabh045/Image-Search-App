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
    let presentAnimator = Animator()
    let dismissAnimator = DismissAnimator()
    var selectedCellFrame = CGRect.zero
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        setupSearchBar()
        setupCollectionView()
        setupConstraints()
        setupViewModel()
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
        imageCollectionView.register(IndicatorReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: IndicatorReusableView.identifier)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView? = nil
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: IndicatorReusableView.identifier, for: indexPath) as! IndicatorReusableView
            footerView.frame = CGRect(x: view.frame.width/2, y: 0, width: 25, height: 25)
            reusableView = footerView
            print("Returning footer")
        }
        return reusableView!
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCellFrame = collectionView.convert(collectionView.layoutAttributesForItem(at: indexPath)!.frame, to: self.view)
        let vc = ImageViewController()
        vc.photoDetails = flickrViewModel.photoDetails.value[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
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

//MARK: TransitionDelegate
extension ViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            presentAnimator.originFrame = selectedCellFrame
            print("Frame is",selectedCellFrame)
            return presentAnimator
        case .pop:
            dismissAnimator.originFrame = selectedCellFrame
            return dismissAnimator
        default:
            return nil
        }
        
    }

}




