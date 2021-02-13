//
//  SearchViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/10/21.
//

import SnapKit

class SearchViewController: UIViewController {

    let viewModel = SearchViewModel()

    private var scopeButtonIndex = 0
    private var searchText = ""
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = UIColor(named: "DarkTheme")
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PostsCustomCell.self, forCellWithReuseIdentifier: String(describing: PostsCustomCell.self))
        collectionView.register(CollectionsCustomCell.self, forCellWithReuseIdentifier: String(describing: CollectionsCustomCell.self))
        collectionView.register(UsersCustomCell.self, forCellWithReuseIdentifier: String(describing: UsersCustomCell.self))
        collectionView.alpha = 0
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = UIColor(named: "DarkTheme")
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsScopeBar = true
        searchBar.tintColor = .white
        searchBar.scopeButtonTitles = ["Photos", "Collections", "Users"]
        searchBar.barTintColor = UIColor(named: "DarkTheme")
        searchBar.backgroundColor = UIColor(named: "DarkTheme")
        return searchBar
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "DarkTheme")
        layoutUI()
        bindViewModel()
    }
    
    private func layoutUI() {
        configureSearchBar()
        configureTableView()
        configureCollectionView()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        tabBarController?.navigationItem.titleView = searchBar
        tabBarController?.navigationController?.navigationBar.isTranslucent = false
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.right.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func createGradient(with frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.1, 1]
        return gradient
    }
    
    private func bindViewModel() {
        viewModel.didEndRequest = { [weak self] indexPaths in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.performBatchUpdates {
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
}

// MARK: Table View Data Source
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        cell.textLabel?.text = "Test"
        return cell
    }
}

// MARK: Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text ?? "cats"
        collectionView.setContentOffset(.zero, animated: true)
        tableView.alpha = 0
        collectionView.alpha = 1.0
        viewModel.newQuery()
        viewModel.fetchData(searchText: searchText, scopeButtonIndex: scopeButtonIndex)
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.alpha = 1.0
            collectionView.alpha = 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        viewModel.newQuery()
        collectionView.reloadData()
        scopeButtonIndex = selectedScope
        viewModel.fetchData(searchText: searchText, scopeButtonIndex: scopeButtonIndex)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch scopeButtonIndex {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostsCustomCell.self), for: indexPath) as! PostsCustomCell
            let post = viewModel.results[indexPath.row] as! Post

            cell.cellImageView.image = nil
            cell.cellImageView.backgroundColor = UIColor(hex: post.color)

            viewModel.image(url: post.urls.regular) { [weak self] image, error  in
                guard let img = image else { return }
                DispatchQueue.main.async {
                    cell.cellImageView.image = img
                    cell.userNameLabel.text = post.user.name
                    cell.cellImageView.layer.mask = self?.createGradient(with: cell.cellImageView.bounds)
                }
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionsCustomCell.self),
                                                          for: indexPath) as! CollectionsCustomCell
            let collection = viewModel.results[indexPath.row] as! Collection

            cell.collectionImageView.image = nil

            viewModel.image(url: collection.cover_photo.urls.regular) { image, error  in
                guard let img = image else { return }
                DispatchQueue.main.async {
                    cell.collectionImageView.image = img
                    cell.collectionNameLabel.text = collection.title
                }
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UsersCustomCell.self), for: indexPath) as! UsersCustomCell
            let user = viewModel.results[indexPath.row] as! User

            cell.userImageView.image = nil
            cell.userImageView.backgroundColor = UIColor(hex: user.profile_image.medium)
            
            viewModel.image(url: user.profile_image.medium) { image, error  in
                guard let img = image else { return }
                DispatchQueue.main.async {
                    cell.userImageView.image = img
                    cell.nameLabel.text = user.name
                    cell.userNameLabel.text = user.username
                }
            }
            return cell
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Size for item at index path
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch scopeButtonIndex {
        case 0:
            let post = viewModel.results[indexPath.row] as! Post
            return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
        case 1:
            return CGSize(width: view.frame.width - 20, height: 200)
        default:
            return CGSize(width: view.frame.width , height: 100)
        }
    }
}


extension SearchViewController: UIScrollViewDelegate {
    
    // MARK: Scroll view did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get the current vertical position of collectionView
        
        let position = scrollView.contentOffset.y
        let distanceToTheEndOfScrollView = collectionView.contentSize.height - 100 - scrollView.frame.size.height
        if position > distanceToTheEndOfScrollView {
            viewModel.fetchData(searchText: searchText, scopeButtonIndex: scopeButtonIndex)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}
