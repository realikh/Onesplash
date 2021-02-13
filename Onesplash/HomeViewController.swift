//
//  ViewController.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import SnapKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PostsCustomCell.self, forCellWithReuseIdentifier: String(describing: PostsCustomCell.self))
        collectionView.contentInsetAdjustmentBehavior  = .never
        return collectionView
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
    }()
    
    
    // MARK: Layout
    private func layoutUI() {
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.register(FooterCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: String(describing: FooterCollectionReusableView.self))
    }
    
    private func createGradient(with frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.1, 1]
        return gradient
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        viewModel.fetchPosts()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        tabBarController?.navigationController?.navigationBar.titleTextAttributes = textAttributes
        tabBarController?.navigationItem.title = "UNSPLASH"
        tabBarController?.navigationItem.titleView = .none
    }
}


extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostsCustomCell.self),
                                                      for: indexPath) as! PostsCustomCell
        let post = viewModel.posts[indexPath.row]
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
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: FooterCollectionReusableView.self), for: indexPath) as! FooterCollectionReusableView
        
        footer.configure()
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }
}

// MARK: ScrollViewDelegate
// Handle when user scrolled to the bottom of collectionView and fetch more data
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get the current vertical position of collectionView
        let position = scrollView.contentOffset.y
        let distanceToTheEndOfScrollView = collectionView.contentSize.height - 100 - scrollView.frame.size.height
        if position > distanceToTheEndOfScrollView {
            viewModel.fetchPosts()
        }
    }
}


// MARK: CollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = viewModel.posts[indexPath.row]
        return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
    }
}


