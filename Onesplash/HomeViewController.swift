//
//  ViewController.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import SnapKit

class HomeViewController: UIViewController {
    
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
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        
        postService.posts(query: "cartoon") { [weak self] posts, error in
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

extension HomeViewController: UICollectionViewDelegate {
    
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
            let img = image(data: data)
            
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
    func collectionView      (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}
