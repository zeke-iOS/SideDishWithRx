//
//  ImagesScrollView.swift
//  SideDishWithRx
//
//  Created by 양준혁 on 2021/08/12.
//

import UIKit
import SnapKit

final class ImagesScrollView: UIScrollView {

    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isPagingEnabled = true
        addSubview(contentView)
        configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureContentView(view: UIView) {
        self.contentView.addSubview(view)
    }
}

extension ImagesScrollView {
    private func configureAutoLayout() {
        contentView.snp.makeConstraints { view in
            view.edges.equalToSuperview()
            view.centerX.centerY.equalToSuperview()
        }
    }
}
