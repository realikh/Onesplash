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
    
    var posts = [Post]()
    
    var results = [Post]()
    
    private let vc = HomeViewController()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CustomCollectionViewCell.self))
        collectionView.alpha = 0
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["Photos", "Collections", "Users"]
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutUI()
    }
    
    private func layoutUI() {
        configureSearchBar()
        configureTableView()
        configureCollectionView()
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
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        tabBarController?.navigationItem.titleView = searchBar
        tabBarController?.navigationController?.navigationBar.isTranslucent = false
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
    
}

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

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPosts(with: searchBar.text!)
        searchBar.endEditing(true)
        tableView.alpha = 0
        collectionView.alpha = 1.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            tableView.alpha = 1.0
            collectionView.alpha = 0
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomCollectionViewCell.self),
                                                      for: indexPath) as! CustomCollectionViewCell
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
                
                let gradient = CAGradientLayer()
                gradient.frame = cell.cellImageView.bounds
                gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
                gradient.locations = [0.1, 1]
                cell.cellImageView.layer.mask = gradient
            }
        }
        return cell
    }
}



extension SearchViewController: UICollectionViewDelegate {
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}

