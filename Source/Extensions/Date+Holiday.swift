//
//  Date+Holiday.swift
//  CalendarKit
//
//  Created by Shinji-Muto on 2018/07/23.
//

import Foundation
import CalculateCalendarLogic

extension Date {
    
    /// 日本の祝日かどうかを返す
    ///
    /// - Returns: 日本の祝日かどうか
    func isJapaneseHoliday() -> Bool {
        
        let calendar = Calendar.init(identifier: .gregorian)
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        
        let calendarLogicHoliday = CalculateCalendarLogic()
        
        return calendarLogicHoliday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
}
