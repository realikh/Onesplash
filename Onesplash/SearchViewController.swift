//
//  SearchViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/10/21.
//

import SnapKit

class SearchViewController: UIViewController {
    
    private var images = [UIImage]()
    
    let postService = PostService.shared
    let collectionService = CollectionService.shared
    let userService = UserService.shared
    
    var posts = [Post]()
    var collections = [Collection]()
    var users = [User]()
    
    var results = [Post]()
    var collectionResult = [Collection]()
    var userResults = [User]()
    
    private var recentSearches = [String]()
    
    private var scopeButtonIndex = 0
    
    
    private let vc = HomeViewController()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = UIColor(named: "DarkTheme")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
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
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = .white
        searchBar.barTintColor = UIColor(named: "DarkTheme")
        searchBar.backgroundColor = UIColor(named: "DarkTheme")
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        return searchBar
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Photos", "Collections", "Users"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "DarkTheme")
        layoutUI()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutUI()
    }
    
    private func layoutUI() {
        configureSearchBar()
        configureSegmentedControl()
        configureTableView()
        configureCollectionView()
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalTo(view.safeAreaLayoutGuide).offset(19)
            $0.right.equalTo(view.safeAreaLayoutGuide).offset(-19)
            $0.height.equalTo(30)
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.right.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.right.equalTo(view.safeAreaLayoutGuide)
            $0.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        tabBarController?.navigationItem.titleView = searchBar
        tabBarController?.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(named: "DarkTheme")
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filters"),
                                                                              style: .plain,
                                                                            target: self, action: #selector(lol))
        tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    @objc func lol(){
        print("lol")
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        scopeButtonIndex = sender.selectedSegmentIndex
        switch scopeButtonIndex {
        case 0:
            searchPosts(with: searchBar.text!)
            tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filters"),
                                                                                  style: .plain,
                                                                                target: self, action: #selector(lol))
            tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .white
        case 1:
            searchCollections(with: searchBar.text!)
            tabBarController?.navigationItem.rightBarButtonItem = .none
        default:
            searchUsers(with: searchBar.text!)
            tabBarController?.navigationItem.rightBarButtonItem = .none
        }
    }
    
    private func searchPosts(with query: String) {
        postService.searchPosts(with: query) { [weak self] posts, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self?.posts = posts!
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
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

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = recentSearches[indexPath.row]
        cell.backgroundColor = UIColor(named: "DarkTheme")
        cell.textLabel?.textColor = .white
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CustomSearchHeaderView()
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scopeButtonIndex = segmentedControl.selectedSegmentIndex
        tableView.alpha = 0
        collectionView.alpha = 1.0
        searchBar.text = recentSearches[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        switch scopeButtonIndex {
        case 0:
            searchPosts(with: searchBar.text!)
            searchBar.endEditing(true)
        case 1:
            searchCollections(with: searchBar.text!)
            searchBar.endEditing(true)
        default:
            searchUsers(with: searchBar.text!)
            searchBar.endEditing(true)
        }
    }
      
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        scopeButtonIndex = segmentedControl.selectedSegmentIndex
        tableView.alpha = 0
        collectionView.alpha = 1.0
        recentSearches.append(searchBar.text!)
        tableView.reloadData()
        switch scopeButtonIndex {
        case 0:
            searchPosts(with: searchBar.text!)
            searchBar.endEditing(true)
        case 1:
            searchCollections(with: searchBar.text!)
            searchBar.endEditing(true)
        default:
            searchUsers(with: searchBar.text!)
            searchBar.endEditing(true)
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            tableView.alpha = 1.0
            collectionView.alpha = 0
            print(segmentedControl.selectedSegmentIndex)
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch scopeButtonIndex {
        case 0:
            return posts.count
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
            let post = posts[indexPath.row]
            
            cell.cellImageView.image = nil
            cell.cellImageView.backgroundColor = UIColor(hex: post.color)
            
            func image(data: Data?) -> UIImage? {
                if let data = data {
                    return UIImage(data: data)
                }
                return UIImage(systemName: "picture")
            }
            
            postService.image(post: post) { [weak self] data, error  in
                guard let img = image(data: data) else { return }
                self?.images.append(img)
                DispatchQueue.main.async {
                    cell.cellImageView.image = img
                    cell.userNameLabel.text = post.user.name
                    cell.cellImageView.setupImageViewer(options: [.theme(.dark), .rightNavItemTitle("Download", onTap: { (Int) in
                        print("download")
                    })], from: self)
                    
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
            
            postService.image(post: collection.cover_photo) { [weak self] data, error  in
                guard let img = image(data: data) else { return }
                self?.images.append(img)
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
                self?.images.append(img)
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



extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if scopeButtonIndex == 1 {
            let collection = collections[indexPath.row]
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            let vc = ExpandedCollectionViewController()
            vc.collectionId = Int(collection.id)
            vc.collectionOwner = collection.user.name
            vc.collectionTitle = collection.title
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch scopeButtonIndex {
        case 0:
            let post = posts[indexPath.row]
            return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
        case 1:
            return CGSize(width: view.frame.width - 20, height: 200)
        default:
            return CGSize(width: view.frame.width , height: 100)
        }
        
    }
}


