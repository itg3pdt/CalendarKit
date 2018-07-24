import UIKit
import DateToolsSwift

extension Date {
    func dayColor(style: DaySelectorStyle) -> UIColor {
        switch self.component(.weekday) {
        case 1:
            return style.sundayColor
        case 7:
            return style.saturdayColor
        default:
            return style.inactiveTextColor
        }
    }
}

class DateLabel: UILabel, DaySelectorItemProtocol {
  
  var date = Date() {
    didSet {
      text = String(date.day)
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  var style = DaySelectorStyle()

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 35, height: 35)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    isUserInteractionEnabled = true
    textAlignment = .center
    clipsToBounds = true
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    updateState()
  }

  func updateState() {
    let today = date.isToday
    if selected {
      font = style.todayFont
      textColor = style.activeTextColor
      backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
    } else {
      let notTodayColor = date.dayColor(style: style)
      font = style.font
      
      if today {
        textColor = style.todayInactiveTextColor
      } else if date.isJapaneseHoliday() {
        textColor = style.holidayColor
      } else {
        textColor = notTodayColor
      }
        
      backgroundColor = style.inactiveBackgroundColor
    }
  }

  func animate(){
    UIView.transition(with: self,
                      duration: 0.4,
                      options: .transitionCrossDissolve,
                      animations: {
                        self.updateState()
    }, completion: nil)
  }

  override func layoutSubviews() {
    layer.cornerRadius = bounds.height / 2
  }
  override func tintColorDidChange() {
    updateState()
  }
}
