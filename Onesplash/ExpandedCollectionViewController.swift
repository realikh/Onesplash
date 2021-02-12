//
//  ExpandedCollectionViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import UIKit

class ExpandedCollectionViewController: UIViewController {
    
    let postService = PostService.shared
    private var images = [UIImage]()
    var posts = [Post]()
    var collectionId: Int?
    var collectionOwner: String?
    var collectionTitle: String?
    lazy var ownerString = "Curated by \(collectionOwner!)"
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PostsCustomCell.self, forCellWithReuseIdentifier: String(describing: PostsCustomCell.self))
        return collectionView
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        retrievePosts(with: collectionId!)
        navigationController?.navigationBar.backItem?.backButtonTitle = ""
        navigationController?.navigationBar.barTintColor = UIColor(named: "DarkTheme")
        navigationController?.navigationBar.tintColor = .white
        navigationItem.setTitle(title: collectionTitle!, subtitle: ownerString)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func retrievePosts(with id: Int) {
        postService.retrieveCollectionPhotos(with: collectionId!, pageNumber: 1) { [weak self] posts, error in
            if let error = error {
                print(error)
                return
            }
            
            self?.posts = posts!
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

extension ExpandedCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

extension ExpandedCollectionViewController: UICollectionViewDelegate {
    
}

extension ExpandedCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}

extension UINavigationItem {
    func setTitle(title:String, subtitle:String) {
        
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 20)
        one.textColor = .white
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textColor = .gray
        two.textAlignment = .center
        two.sizeToFit()
        
        
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        
        
        self.titleView = stackView
    }
}
