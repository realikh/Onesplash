//
//  ViewController.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import SnapKit

class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let postService = PostService.shared
    
    var posts = [Post]()
    
    var results = [Post]()
    
    // MARK: Layout
    private func layoutUI() {
        configureTableView()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: String(describing: ImageTableViewCell.self))
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
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
                self?.tableView.reloadData()
            }
        }
    }
}


extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView:  UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTableViewCell.self)) as! ImageTableViewCell
        
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
                cell.contentView.heightAnchor.constraint(equalToConstant: CGFloat(post.height / post.width) * cell.contentView.bounds.width).isActive = true
                cell.cellImageView.image = img
                cell.cellImageView.clipsToBounds = true
                cell.userNameLabel.text = post.user.name
          }
        }
        return cell
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
