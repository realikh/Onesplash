//
//  SearchViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/10/21.
//

import SnapKit

class SearchViewController: UIViewController {
    
    let viewModel = SearchViewModel()
    let headerView = CustomSearchHeaderView()
    let filtersVC = FiltersViewController()
    
    private var scopeButtonIndex = 0
    private var searchText = ""
    
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
        collectionView.register(PostsCustomCell.self,
                                forCellWithReuseIdentifier: String(describing: PostsCustomCell.self))
        collectionView.register(CollectionsCustomCell.self,
                                forCellWithReuseIdentifier: String(describing: CollectionsCustomCell.self))
        collectionView.register(UsersCustomCell.self,
                                forCellWithReuseIdentifier: String(describing: UsersCustomCell.self))
        collectionView.alpha = 0
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = UIColor(named: "DarkTheme")
        return collectionView
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
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        return collectionViewFlowLayout
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
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.fetchSearchHistory()
        layoutUI()
        bindViewModel()
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
                                                                              target: self, action: #selector(presentFilters))
        tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    @objc func presentFilters(){
        present(filtersVC, animated: true, completion: nil)
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
//        viewModel.requestCancelled = true
        scopeButtonIndex = sender.selectedSegmentIndex
        viewModel.newQuery()
        collectionView.reloadData()
        switch scopeButtonIndex {
        case 0:
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 0)
            tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filters"),
                                                                                  style: .plain,
                                                                                  target: self, action: #selector(presentFilters))
            tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .white
        case 1:
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 1)
            tabBarController?.navigationItem.rightBarButtonItem = .none
        default:
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 2)
            tabBarController?.navigationItem.rightBarButtonItem = .none
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
        headerView.clearButtonPressed = {
            self.viewModel.deleteSearchRecords()
            
            self.tableView.reloadData()
        }
    }
}

// MARK: Table View Data Source
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = viewModel.recentSearches[indexPath.row].title
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
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scopeButtonIndex = segmentedControl.selectedSegmentIndex
        tableView.alpha = 0
        collectionView.alpha = 1.0
        searchBar.text = viewModel.recentSearches[indexPath.row].title
        tableView.deselectRow(at: indexPath, animated: true)
        switch scopeButtonIndex {
        case 0:
            viewModel.newQuery()
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 0)
            searchBar.endEditing(true)
        case 1:
            viewModel.newQuery()
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 1)
            searchBar.endEditing(true)
        default:
            viewModel.newQuery()
            viewModel.fetchData(searchText: searchBar.text!, scopeButtonIndex: 2)
            searchBar.endEditing(true)
        }
    }
}

// MARK: Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        scopeButtonIndex = segmentedControl.selectedSegmentIndex
        searchText = searchBar.text ?? "cats"
        collectionView.setContentOffset(.zero, animated: true)
        tableView.alpha = 0
        collectionView.alpha = 1.0
        viewModel.addRecentSearch(string: searchBar.text!)
        viewModel.newQuery()
        collectionView.reloadData()
        viewModel.fetchData(searchText: searchText, scopeButtonIndex: scopeButtonIndex)
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.reloadData()
            tableView.alpha = 1.0
            collectionView.alpha = 0
        }
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
            
            guard let post = viewModel.results[indexPath.row] as? Post else { return cell }
            
            cell.cellImageView.image = nil
            cell.cellImageView.backgroundColor = UIColor(hex: post.color)
            
            viewModel.image(url: post.urls.regular) { [weak self] image, error  in
                guard let img = image else { return }
                DispatchQueue.main.async {
                    cell.cellImageView.image = img
                    cell.userNameLabel.text = post.user.name
                    cell.cellImageView.layer.mask = self?.createGradient(with: cell.cellImageView.bounds)
                    cell.cellImageView.setupImageViewer()
                                   cell.cellImageView.setupImageViewer(options: [.theme(.dark), .rightNavItemTitle("Download", onTap: { (Int) in
                                       print("download")
                                   })], from: self)
                }
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionsCustomCell.self),
                                                          for: indexPath) as! CollectionsCustomCell

            guard let collection = viewModel.results[indexPath.row] as? Collection else { return cell }
            
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
            guard let user = viewModel.results[indexPath.row] as? User else { return cell }
            
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
            if let post = viewModel.results[indexPath.row] as? Post {
                return CGSize(width: view.frame.width, height: CGFloat(350 * (post.height/post.width)))
            }
            return CGSize(width: view.frame.width - 20, height: 200)
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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if scopeButtonIndex == 1 {
            let collection = viewModel.results[indexPath.row] as! Collection
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
