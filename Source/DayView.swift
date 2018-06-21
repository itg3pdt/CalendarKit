import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidPanEventView(_ eventView: EventView)
  func dayViewDidLongPressTimelineAtHour(_ hour: Int)
  func dayViewDidTap(_ timelineView: TimelineView)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
}

public class DayView: UIView {

  public weak var dataSource: EventDataSource? {
    get {
      return timelinePagerView.dataSource
    }
    set(value) {
      timelinePagerView.dataSource = value
    }
  }

  public weak var delegate: DayViewDelegate?

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      setNeedsLayout()
    }
  }

  public var timelineScrollOffset: CGPoint {
    return timelinePagerView.timelineScrollOffset
  }

  static let headerVisibleHeight: CGFloat = 88
  var headerHeight: CGFloat = headerVisibleHeight
    
  static let footerHeight: CGFloat = 35

  open var autoScrollToFirstEvent: Bool {
    get {
      return timelinePagerView.autoScrollToFirstEvent
    }
    set (value) {
      timelinePagerView.autoScrollToFirstEvent = value
    }
  }

  let dayHeaderView = DayHeaderView()
  let timelinePagerView = TimelinePagerView()
  let footerView = FooterView()

  public var state: DayViewState? {
    didSet {
      dayHeaderView.state = state
      timelinePagerView.state = state
    }
  }

  var style = CalendarStyle()
    
  public var draggableEventView: EventView?
    
  public var pastBusinessDate: Date?

  public init(state: DayViewState) {
    super.init(frame: .zero)
    self.state = state
    configure()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    addSubview(timelinePagerView)
    addSubview(dayHeaderView)
    addSubview(footerView)
    timelinePagerView.delegate = self

    if state == nil {
      state = DayViewState()
    }
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle.copy() as! CalendarStyle
    dayHeaderView.updateStyle(style.header)
    timelinePagerView.updateStyle(style.timeline)
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    timelinePagerView.timelinePanGestureRequire(toFail: gesture)
  }

  public func scrollTo(hour24: Float) {
    timelinePagerView.scrollTo(hour24: hour24)
  }

  public func scrollToFirstEventIfNeeded() {
    timelinePagerView.scrollToFirstEventIfNeeded()
  }

  public func reloadData() {
    timelinePagerView.reloadData()
  }

  public func updateAggregatedData(price: Int, count: Int) {
    footerView.updateAggregatedData(price: price, count: count)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    footerView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 0, otherSize: DayView.footerHeight)
    timelinePagerView.alignBetweenVertical(align: .underCentered, primaryView: dayHeaderView, secondaryView: footerView, padding: 0, width: dayHeaderView.bounds.width)  }

  public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
    dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
    updateStyle(style)
  }
}

extension DayView: EventViewDelegate {
  public func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
  public func eventView(_ eventView: EventView, didMoveTo translation: CGPoint) {
    delegate?.dayViewDidPanEventView(eventView)
  }
  public func eventView(_ eventView: EventView, didExpandAndContractTo translation: CGPoint) {
    delegate?.dayViewDidPanEventView(eventView)
  }
}

extension DayView: TimelinePagerViewDelegate {
  public func timelinePagerDidSelectEventView(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
    delegate?.dayViewDidLongPressEventView(eventView)
  }
  public func timelinePagerDidPanEventView(_ eventView: EventView) {
    delegate?.dayViewDidPanEventView(eventView)
  }
  public func timelinePagerDidLongPressTimelineAtHour(_ hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
  public func timelinePagerDidTap(_ timelineView: TimelineView) {
    delegate?.dayViewDidTap(timelineView)
  }
  public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
    delegate?.dayView(dayView: self, willMoveTo: date)
  }
  public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
    delegate?.dayView(dayView: self, didMoveTo: date)
  }
}

extension DayView: TimelineViewDelegate {
  public func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
  public func timelineViewDidTap(_ timelineView: TimelineView) {
    delegate?.dayViewDidTap(timelineView)
  }
}

extension DayView {
    
  /// Timelineに対して影のレイヤーを追加する
  ///
  /// - Parameters:
  ///   - startPoint: 追加する始点(0.0~24.0。少数点は分を示す)
  ///   - shadowLength: レイヤーの長さ(0.0~24.0。小数点は分を示す)
  public func addShadowLayer(startPoint: CGFloat, shadowLength: CGFloat) {
    timelinePagerView.addShadowLayer(startPoint: startPoint, shadowLength: shadowLength)
  }
    
}
