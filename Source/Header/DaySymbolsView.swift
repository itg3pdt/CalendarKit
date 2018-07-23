import UIKit
import DateToolsSwift

enum DayOfTheWeek: Int {
    case sunday, saturday, weekday
}

class DaySymbolsView: UIView {

  var daysInWeek = 7
  var calendar = Calendar.autoupdatingCurrent
  var labels = [UILabel]()
  var style: DaySymbolsStyle = DaySymbolsStyle()

  var startDate: Date?
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  init(daysInWeek: Int = 7) {
    super.init(frame: CGRect.zero)
    self.daysInWeek = daysInWeek
    initializeViews()
  }

  func initializeViews() {
    for _ in 1...daysInWeek {
      let label = UILabel()
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    configure()
  }

  func updateStyle(_ newStyle: DaySymbolsStyle) {
    style = newStyle.copy() as! DaySymbolsStyle
    configure()
    setHolidayColor()
  }

  func configure() {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    let daySymbols = calendar.veryShortWeekdaySymbols
    let weekendMask: [DayOfTheWeek] = [.sunday] + [DayOfTheWeek](repeating: .weekday, count: 5) + [.saturday]
    var weekDays = Array(zip(daySymbols, weekendMask))

    weekDays.shift(calendar.firstWeekday - 1)

    for (index, label) in labels.enumerated() {
        label.text = weekDays[index].0
        switch weekDays[index].1 {
        case .sunday:
            label.textColor = style.sundayColor
        case .saturday:
            label.textColor = style.saturdayColor
        case .weekday:
            label.textColor = style.weekDayColor
        }
        label.font = style.font
    }
  }


  override func layoutSubviews() {
    let labelsCount = CGFloat(labels.count)

    var per = bounds.width - bounds.height * labelsCount
    per /= labelsCount

    let minX = per / 2
    for (i, label) in labels.enumerated() {
      let frame = CGRect(x: minX + (bounds.height + per) * CGFloat(i), y: 0,
                         width: bounds.height, height: bounds.height)
      label.frame = frame
    }
  }
}

extension DaySymbolsView {

  /// 現在のSymbolのうち祝日に該当するSymbolの文字色をholidayColorに変更する
  func setHolidayColor() {
    guard startDate != nil else {
        return
    }
    for (index, label) in labels.enumerated() {
      let targetDate = startDate.add(TimeChunk.dateComponents(days: index))
      if targetDate.isJapaneseHoliday() {
        label.textColor = style.holidayColor
      }
    }
  }
}

