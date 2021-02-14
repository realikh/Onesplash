
import ImageViewer_swift

class ExpandedCollectionViewController: UIViewController {
    
    private var viewModel = ExpandedCollectionViewModel()
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
        viewModel.fetchPosts(with: collectionId!)
        bindViewModel()
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
    
    private func bindViewModel() {
        viewModel.didEndRequest = { indexPaths in
            guard let  indexPaths = indexPaths else { return }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
}

extension ExpandedCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PostsCustomCell.self),
                                                      for: indexPath) as! PostsCustomCell
        
        let post = viewModel.results[indexPath.row] as! Post
        
        cell.cellImageView.image = nil
        cell.cellImageView.backgroundColor = UIColor(hex: post.color)
        
        viewModel.image(url: post.urls.regular) { image, error  in
            guard let img = image else { return }
            DispatchQueue.main.async {
                cell.cellImageView.image = img
                cell.userNameLabel.text = post.user.name
                cell.cellImageView.setupImageViewer()
                               cell.cellImageView.setupImageViewer(options: [.theme(.dark), .rightNavItemTitle("Download", onTap: { (Int) in
                                   print("download")
                               })], from: self)
            }
        }
        return cell
    }
}

extension ExpandedCollectionViewController: UICollectionViewDelegate {
    
}

extension ExpandedCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = viewModel.results[indexPath.row] as! Post
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
