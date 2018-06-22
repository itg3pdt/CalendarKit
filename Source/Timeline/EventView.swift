import UIKit
import DateToolsSwift
import Neon

enum KindsOfGestures: Int {
  case Move, ExpansionAndContraction, None
}

public protocol EventViewDelegate: class {
  func eventViewDidTap(_ eventView: EventView)
  func eventViewDidLongPress(_ eventview: EventView)
  func eventView(_ eventView: EventView, didMoveTo translation: CGPoint)
  func eventView(_ eventView: EventView, didExpandAndContractTo translation: CGPoint)
}

open class EventView: UIView {

  weak var delegate: EventViewDelegate?
  public var descriptor: EventDescriptor?

  public var color = UIColor.lightGray

  var panStatus: KindsOfGestures = .None
  var panStartCenter: CGPoint = .zero
  var panStartFrame: CGRect = .zero
  var panLocation: CGPoint = .zero
  let stretchableInset: CGFloat = 20
  let fake15: CGFloat = 45 * (15 / 60)
  
  var contentHeight: CGFloat {
    return textView.height
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    return view
  }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
  lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    color = tintColor
    addSubview(textView)
  }

  func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
      textView.attributedText = attributedText
    } else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
    }
    descriptor = event
    backgroundColor = event.backgroundColor
    color = event.color
    setNeedsDisplay()
    setNeedsLayout()
  }

  @objc func tap() {
    delegate?.eventViewDidTap(self)
  }

  @objc func longPress() {
    delegate?.eventViewDidLongPress(self)
  }
    
  @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
    let translation = gestureRecognizer.translation(in: self)
    switch gestureRecognizer.state {
    case .began:
      // ドラッグに関するステータスを設定する
      panStartCenter = center
      panStartFrame = frame
      panLocation = gestureRecognizer.location(in: self)
      panStatus = (panLocation.y < stretchableInset || panLocation.y > bounds.height - stretchableInset) ? .ExpansionAndContraction : .Move
    case .changed:
      guard let a = Int(abs(translation.y) / fake15) > 0 ? Int(translation.y / fake15) : nil else {
        return
      }
      if panStatus == .ExpansionAndContraction {
        // TODO: 最小値より縮ませない
        guard bounds.height > fake15 * 2 else {
          return
        }
        if panLocation.y < stretchableInset {
          print("top")
          // トップを伸縮させる
          frame = CGRect(x: frame.origin.x, y: panStartFrame.origin.y + fake15 * CGFloat(a), width: bounds.width, height: panStartFrame.height - fake15 * CGFloat(a))
          // 開始日を再設定する
          let (hour, minutes) = yToTime(frame.origin.y)
          guard let descri = descriptor as? Event else {
            return
          }
          descri.startDate.hour(hour)
          descri.startDate.minute(minutes)
        } else {
          // ボトムを伸縮させる
          frame = CGRect(origin: frame.origin, size: CGSize(width: bounds.width, height: panStartFrame.height + fake15 * CGFloat(a)))
          // 終了日を再設定する
          let destY = frame.origin.y + bounds.height
          let (hour, minutes) = yToTime(destY)
          guard let _descriptor = descriptor as? Event else {
            return
          }
          _descriptor.endDate.hour(hour)
          _descriptor.endDate.minute(minutes)
        }
        delegate?.eventView(self, didExpandAndContractTo: translation)
      } else if panStatus == .Move {
        // 移動させる
        center = CGPoint(x: panStartCenter.x + translation.x, y: panStartCenter.y + fake15 * CGFloat(a))
        // 日付を再設定する
        let (hour, minutes) = yToTime(frame.origin.y)
        guard let _descriptor = descriptor as? Event else {
          return
        }
        let period = TimePeriod(beginning: descriptor?.startDate, end: descriptor?.endDate)
        _descriptor.startDate.hour(hour)
        _descriptor.startDate.minute(minutes)
        _descriptor.endDate = _descriptor.startDate.add(period.chunk)
        delegate?.eventView(self, didMoveTo: translation)
      }
    default:
      // ドラッグに関するステータスをリセットする
      panStartCenter = .zero
      panStartFrame = .zero
      panLocation = .zero
      panStatus = .None
      return
    }
  }
    
  override open func draw(_ rect: CGRect) {
    super.draw(rect)
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    textView.fillSuperview()
  }
    
  public func select() {
    layer.borderWidth = 3
    layer.borderColor = UIColor.black.cgColor
    addGestureRecognizer(panGestureRecognizer)
    superview?.bringSubview(toFront: self)
  }
    
  public func deselect() {
    layer.borderWidth = 0
    removeGestureRecognizer(panGestureRecognizer)
    updateWithDescriptor(event: descriptor!)
    superview?.setNeedsLayout()
  }
    
  fileprivate func yToTime(_ y: CGFloat) -> (Int, Int) {
    let verticalDiff: CGFloat = 45
    let verticalInset: CGFloat = 10
    let hour = Int((y - verticalInset) / verticalDiff)
    let minutes = Int((y - verticalInset).truncatingRemainder(dividingBy: verticalDiff) / (verticalDiff / 60))
    return (hour, minutes)
  }
}
