//
//  DetailViewModel.swift
//  SideDishWithRx
//
//  Created by 양준혁 on 2021/07/28.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

final class DetailViewModel: HasDisposeBag, ViewModelType {
    struct Input {
        let isFetchDetailDish = BehaviorRelay<Bool>(value: false)
        let isFetchThumbImagesData = BehaviorRelay<Bool>(value: false)
        let isFetchDetailSectionImagesData = BehaviorRelay<Bool>(value: false)
        let plus = PublishSubject<Void>()
        let minus = PublishSubject<Void>()
    }
    
    struct Output {
        let detailDish = PublishRelay<DetailDish>()
        let quantity = BehaviorRelay<Int>(value: 1)
        let price: BehaviorRelay<String>
        let images = PublishRelay<Data>()
        let detailImages = PublishRelay<Data>()
        let title: BehaviorRelay<String>
    }
    
    var repository: RepositoryType
    var sceneCoordinator: SceneCoordinatorType
    let dish: Dish
    var input = Input()
    lazy var output = Output(price: BehaviorRelay<String>(value: dish.sPrice), title: BehaviorRelay<String>(value: dish.title))
    
    init(sceneCoordinator: SceneCoordinatorType, repository: RepositoryType, model: Dish) {
        self.dish = model
        self.sceneCoordinator = sceneCoordinator
        self.repository = repository
        
        //비즈니스 로직
        input.isFetchDetailDish
            .filter { $0 }
            .flatMap { [unowned self] _ in
                self.repository.fetchDetailDish(endPoint: EndPoint(path: .detail), hashID: self.dish.detailHash) }
            .bind(to: output.detailDish)
            .disposed(by: disposeBag)
        
        input.isFetchThumbImagesData
            .filter { $0 }
            .flatMap { [unowned self] _ in self.output.detailDish }
            .flatMap { [unowned self] detailDish in
                self.repository.fetchThumbImagesData(detailDish: detailDish)
            }
            .bind(to: output.images)
            .disposed(by: disposeBag)
        
        input.isFetchDetailSectionImagesData
            .filter { $0 }
            .flatMap { [unowned self] _ in self.output.detailDish }
            .flatMap { [unowned self] detailDish in
                self.repository.fetchDetailSectionImagesData(detailDish: detailDish)
            }
            .bind(to: output.detailImages)
            .disposed(by: disposeBag)

        
        input.plus
            .map { [unowned self] _ in
                output.quantity.value + 1
            }
            .do { [unowned self] value in
                let tempPrice = self.convertStringToInt(price: dish.sPrice)
                let price = self.convertIntToWon(price: tempPrice * value) + "원"
                self.output.price.accept(price)
            }
            .bind(to: output.quantity)
            .disposed(by: disposeBag)
        
        input.minus
            .map { [unowned self] _ in
                let value = output.quantity.value - 1
                return value < 1 ? 1 : value
            }
            .do { [unowned self] value in
                let tempPrice = self.convertStringToInt(price: dish.sPrice)
                let price = self.convertIntToWon(price: tempPrice * value) + "원"
                self.output.price.accept(price)
            }
            .bind(to: output.quantity)
            .disposed(by: disposeBag)
    }

    lazy var popAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.close(animation: true).asObservable().map { _ in }
    }
    
    private func convertStringToInt(price: String) -> Int {
        return Int(price.filter{ $0.isNumber }) ?? 0
    }
    
    private func convertIntToWon(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: price)) ?? "" + "원"
        return result
    }
}
