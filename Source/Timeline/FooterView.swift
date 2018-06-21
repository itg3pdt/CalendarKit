//
//  FooterView.swift
//  CalendarKit
//
//  Created by masaki.koide on 2018/06/12.
//

import UIKit
import Neon

class FooterView: UIView {
    
    let todayLabelWidth: CGFloat = 50
    let priceItemLabelWidth: CGFloat = 30
    let priceValueLabelWidth: CGFloat = 70
    let countItemLabelWidth: CGFloat = 30
    let countValueLabelWidth: CGFloat = 70
    let labelHeight: CGFloat = 30
    let font = UIFont(name: "HelveticaNeue-Thin", size: 11)
    
    let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.groupingSize = 3
        f.currencySymbol = "¥"
        f.currencyCode = "JPY"
        return f
    }()
    
    let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "本日"
        label.textColor = UIColor.white
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var price: Int = 0 {
        didSet {
            priceValueLabel.text = currencyFormatter.string(from: NSNumber(value: price))
        }
    }
    let priceItemLabel: UILabel = {
        let label = UILabel()
        label.text = "売上"
        label.textColor = UIColor.white
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let priceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var count: Int = 0 {
        didSet {
            countValueLabel.text = "\(count) 件"
        }
    }
    let countItemLabel: UILabel = {
        let label = UILabel()
        label.text = "件数"
        label.textColor = UIColor.white
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let countValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        [todayLabel, priceItemLabel, priceValueLabel, countItemLabel, countValueLabel].forEach {
            $0.font = font
            addSubview($0)
        }
        backgroundColor = UIColor(red: 146/255.0, green: 146/255.0, blue: 146/255.0, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        todayLabel.anchorInCorner(.topLeft, xPad: 16, yPad: 2.5, width: todayLabelWidth, height: labelHeight)
        priceItemLabel.align(.toTheRightCentered, relativeTo: todayLabel, padding: 0, width: priceItemLabelWidth, height: labelHeight)
        priceValueLabel.align(.toTheRightCentered, relativeTo: priceItemLabel, padding: 0, width: priceValueLabelWidth, height: labelHeight)
        countItemLabel.align(.toTheRightCentered, relativeTo: priceValueLabel, padding: 0, width: countItemLabelWidth, height: labelHeight)
        countValueLabel.align(.toTheRightCentered, relativeTo: countItemLabel, padding: 0, width: countValueLabelWidth, height: labelHeight)
    }
    
    func updateAggregatedData(price: Int, count: Int) {
        self.price = price
        self.count = count
    }
}

