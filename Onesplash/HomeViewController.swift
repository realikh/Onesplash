//
//  ViewController.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import SnapKit

class HomeViewController: UIViewController {
    
    private var images = [UIImage]()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .black
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CustomCollectionViewCell.self))
        return collectionView
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    let postService = PostService.shared
    
    var posts = [Post]()
    
    var results = [Post]()
    
    // MARK: Layout
    private func layoutUI() {
        configureSearchBar()
        configureCollectionView()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.right.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            $0.edges.equalToSuperview()
        }
    }
    
    private func requestPosts(with query: String) {
        postService.posts(query: query) { [weak self] posts, error in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        
        // "cats" is just a placeholder-query for temporary demonstrative purposes
        requestPosts(with: "cats")
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomCollectionViewCell.self),
                                                      for: indexPath) as! CustomCollectionViewCell
        let post = posts[indexPath.row]
        cell.cellImageView.image = nil
        
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
                // Gradient layer for readability of the user names (especially when there's white image on the background)
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

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        requestPosts(with: searchBar.text!)
    }
    
    //TODO: Hide the keyboard
}
