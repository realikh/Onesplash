//
//  SearchViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/10/21.
//

import SnapKit

class SearchViewController: UIViewController {
    
    let viewModel = SearchViewModel()
    let collectionService = CollectionService.shared
    let userService = UserService.shared
    
    var posts = [Post]()
    var collections = [Collection]()
    var users = [User]()
    
    private var scopeButtonIndex = 0
    
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
    
    private func bindViewModel() {
        viewModel.didEndRequest = { indexPaths in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
    
    private func searchCollections(with query: String) {
        collectionService.searchCollections(with: query) { [weak self] collections, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self?.collections = collections!
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func searchUsers(with query: String) {
        userService.searchUsers(with: query) { [weak self] users, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self?.users = users!
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

// MARK: Table View Data Source
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        tableView.alpha = 0
        collectionView.alpha = 1.0
        switch scopeButtonIndex {
        case 0:
            viewModel.fetchPosts(with: searchBar.text ?? "cats")
        case 1:
            searchCollections(with: searchBar.text!)
        default:
            searchUsers(with: searchBar.text!)
        }
        searchBar.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.alpha = 1.0
            collectionView.alpha = 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scopeButtonIndex = selectedScope
        switch scopeButtonIndex {
        case 0:
            viewModel.fetchPosts(with: searchBar.text ?? "cats")
        case 1:
            searchCollections(with: searchBar.text!)
        default:
            searchUsers(with: searchBar.text!)
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch scopeButtonIndex {
        case 0:
            return viewModel.posts.count
        case 1:
            return collections.count
        default:
            return users.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch scopeButtonIndex {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostsCustomCell.self),
                                                          for: indexPath) as! PostsCustomCell
            let post = viewModel.posts[indexPath.row]
            
            cell.cellImageView.image = nil
            cell.cellImageView.backgroundColor = UIColor(hex: post.color)
            
            func image(data: Data?) -> UIImage? {
                if let data = data {
                    return UIImage(data: data)
                }
                return UIImage(systemName: "picture")
            }
            
            viewModel.image(post: post) { [weak self] image, error  in
                guard let img = image else { return }
                
                DispatchQueue.main.async {
                    cell.cellImageView.image = img
                    cell.userNameLabel.text = post.user.name
                    
                    let gradient = CAGradientLayer()
                    gradient.frame = cell.cellImageView.bounds
                    gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
                    gradient.locations = [0.1, 1]
                    cell.cellImageView.layer.mask = gradient
                }
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionsCustomCell.self),
                                                          for: indexPath) as! CollectionsCustomCell
            let collection = collections[indexPath.row]
            
            cell.collectionImageView.image = nil
            cell.collectionImageView.backgroundColor = UIColor(hex: collection.cover_photo.color)
            
            func image(data: Data?) -> UIImage? {
                if let data = data {
                    return UIImage(data: data)
                }
                return UIImage(systemName: "picture")
            }
            
            viewModel.image(post: collection.cover_photo) { [weak self] image, error  in
                guard let img = image else { return }
                DispatchQueue.main.async {
                    cell.collectionImageView.image = img
                    cell.collectionNameLabel.text = collection.title
                }
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UsersCustomCell.self),
                                                          for: indexPath) as! UsersCustomCell
            let user = users[indexPath.row]
            
            cell.userImageView.image = nil
            cell.userImageView.backgroundColor = UIColor(hex: user.profile_image.medium)
            
            func image(data: Data?) -> UIImage? {
                if let data = data {
                    return UIImage(data: data)
                }
                return UIImage(systemName: "picture")
            }
            
            userService.image(user: user) { [weak self] data, error  in
                guard let img = image(data: data) else { return }
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
            let post = viewModel.posts[indexPath.row]
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
        if position > distanceToTheEndOfScrollView && scopeButtonIndex == 0 {
            viewModel.fetchPosts(with: searchBar.text ?? "cats")
        }
    }
}
