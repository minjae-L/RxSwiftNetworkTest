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
        // 테이블뷰 delegate
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // 테이블뷰 상단 스크롤시 데이터 새로 불러오기
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.viewModel.updateData()
                
                self?.viewModel.refreshLoading.accept(false)
            }
            .disposed(by: disposeBag)
        
        viewModel.refreshLoading
            .subscribe{ [weak self] refreshing in
                if !refreshing {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: disposeBag)
        
        // 테이블뷰 UI 데이터 바인딩
        viewModel.events
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
