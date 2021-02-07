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
        navigationItem.titleView = searchBar
//        view.addSubview(searchBar)
//        searchBar.snp.makeConstraints {
//            $0.left.equalToSuperview()
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//            $0.right.equalToSuperview()
//            $0.height.equalTo(44)
//        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
//            $0.left.equalToSuperview()
//            $0.top.equalTo(searchBar.snp.bottom)
//            $0.right.equalToSuperview()
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.edges.equalToSuperview()
        }
    }
    
    private func fetchPosts() {
        postService.posts { [weak self] posts, error in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        fetchPosts()
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

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPosts(with: searchBar.text!)
        searchBar.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}


// MARK: Extension for UIColor to initialize with hex string
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        return nil
    }
}
