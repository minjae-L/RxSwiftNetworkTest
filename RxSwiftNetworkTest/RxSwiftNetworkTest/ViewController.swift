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

    let urlString = "minjae-L/RandomStudy"
    let disposeBag = DisposeBag()
    private let events = BehaviorRelay<[Events]>(value: [])
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvents(repo: urlString)

    }
    func fetchEvents(repo: String) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            let response = Observable.from([repo])
                .map { urlString -> URL in
                    return URL(string: "https://api.github.com/repos/\(urlString)/events")!
                }
                .map{ url -> URLRequest in
                    return URLRequest(url: url)
                }
                .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                    return URLSession.shared.rx.response(request: request)
                }.share(replay: 1,scope: .whileConnected)
                .filter { response, _ in
                    return 200..<300 ~= response.statusCode
                }
                .map { _, data -> [Events] in
                    let decoder = JSONDecoder()
                    let events = try? decoder.decode([Events].self, from: data)
                    return events ?? []
                }
                .filter { objects in
                    return !objects.isEmpty
                }
                .subscribe { [weak self] newEvents in
                    self?.processEvents(newEvents: newEvents)
                }
                .disposed(by: self?.disposeBag ?? DisposeBag())
        }
    }
    private func processEvents(newEvents: [Events]) {
        var updatedEvents = events.value + newEvents
        if updatedEvents.count > 50 {
            updatedEvents = [Events](updatedEvents.prefix(upTo: 50))
        }
        print(updatedEvents)
        events.accept(updatedEvents)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private func convertTimeDateFormatter(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: string)
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "yyyy년MM월dd일"
        return displayDateFormatter.string(from: date ?? Date())
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        let event = events.value[indexPath.row]
        cell.eventTypeLabel.text = event.type
        cell.userNameLabel.text = event.actor.userName
        cell.userIconImageView.kf.setImage(with: URL(string: event.actor.userIconUrl))
        cell.timeLabel.text = convertTimeDateFormatter(string: event.createdTime)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(events.value[indexPath.row])
    }
    
}
