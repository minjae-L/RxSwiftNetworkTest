//
//  ViewModel.swift
//  RxSwiftNetworkTest
//
//  Created by 이민재 on 7/2/24.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    var events = BehaviorRelay<[Events]>(value: [])
    let disposeBag = DisposeBag()
    
    var refreshLoading = PublishRelay<Bool>()
    
    init() {
        let urlString = "minjae-L/RxSwiftNetworkTest"
        fetchData(urlString: urlString)
    }
    
    private func fetchData(urlString: String){
        Observable.from([urlString])
            .asObservable()
            .map { string in
                return URL(string: "https://api.github.com/repos/\(urlString)/events")!
            }
            .map { url in
                return URLRequest(url: url)
            }
            .flatMap { urlRequest -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: urlRequest)
            }
            .share(replay: 1, scope: .whileConnected)
            .map { _, data -> [Events] in
                let decoder = JSONDecoder()
                let events = try? decoder.decode([Events].self, from: data)
                print("events: \(events)")
                return events ?? []
            }
            .subscribe { [weak self] newEvents in
                self?.processEvents(newEvents: newEvents)
            }
            .disposed(by: disposeBag)
    }
    func updateData() {
        self.fetchData(urlString: "minjae-L/RxSwiftNetworkTest")
    }
    private func processEvents(newEvents: [Events]) {
        var updatedEvents = newEvents
        if updatedEvents.count > 50 {
            updatedEvents = [Events](updatedEvents.prefix(upTo: 50))
        }
        events.accept(updatedEvents)
    }
    func convertTimeDateFormatter(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: string)
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "yyyy년MM월dd일\nHH시mm분"
        return displayDateFormatter.string(from: date ?? Date())
    }
}
