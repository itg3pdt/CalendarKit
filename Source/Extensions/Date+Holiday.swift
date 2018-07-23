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
        let dateSlashFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = Calendar.current.timeZone
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return dateFormatter
        }()
            
        let calendarLogicHoliday = CalculateCalendarLogic()
        let tmp = dateSlashFormatter.string(from: self)
        let dateArray = tmp.split(separator: "/")
        guard let yyyy = Int(dateArray[0]),
                let mm = Int(dateArray[1]),
                let dd = Int(dateArray[2]) else {
                return false
        }
        
        return calendarLogicHoliday.judgeJapaneseHoliday(year: yyyy, month: mm, day: dd)
    }
}
