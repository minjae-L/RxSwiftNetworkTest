//
//  ViewController.swift
//  RxSwiftNetworkTest
//
//  Created by 이민재 on 7/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    private let viewModel = ViewModel()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel
            .events
            .observe(on: MainScheduler.instance)
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) {(index, element, cell) in
                cell.userNameLabel.text = "\(element.actor.userName)"
                cell.eventTypeLabel.text = "\(element.type)"
                cell.timeLabel.text = "\(element.createdTime)"
                cell.userIconImageView.kf.setImage(with: URL(string: element.actor.userIconUrl))
            }
            .disposed(by: disposeBag)
        
        
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
