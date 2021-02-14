//
//  FiltersViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/14/21.
//

import UIKit

class FiltersViewController: UIViewController {
    
    private var viewModel = FiltersViewModel()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = UIColor(named: "DarkTheme")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureNavBar()
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureNavBar() {
        navigationController?.navigationItem.title = "Filters"
    }
}

extension FiltersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self),
                                                 for: indexPath)
        cell.textLabel?.text = viewModel.data[indexPath.section][indexPath.row]
        cell.backgroundColor = .darkGray
        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
        }

        let view = UIView()
        view.backgroundColor = .gray
        cell.selectedBackgroundView = view
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < viewModel.headers.count {
            return viewModel.headers[section]
        }
        return nil
    }
}

extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
       if let headerView = view as? UITableViewHeaderFooterView {
        headerView.contentView.backgroundColor = UIColor(named: "DarkTheme")
        headerView.textLabel?.textColor = .gray
       }
   }
}
