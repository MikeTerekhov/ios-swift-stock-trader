//
//  ChartGenerator.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/17/24.
//

import Foundation

let baseURL = Constants.baseURL

func generateChartDates() -> (from: String, to: String)? {
    let calendar = Calendar.current
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // The year should be in lowercase "yyyy"
    dateFormatter.timeZone = TimeZone(identifier: "America/New_York") // NYSE timezone

    let dayOfWeek = calendar.component(.weekday, from: today)
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let dayOfWeekName = daysOfWeek[dayOfWeek - 1]

    guard let lastOpenDay = getLastOpenDate() else { return nil }
    let lastOpenDayString = dateFormatter.string(from: lastOpenDay)
    let oneDayEarlierString = dateFormatter.string(from: calendar.date(byAdding: .day, value: -1, to: lastOpenDay)!)

    let from: String
    let to: String
    
    switch dayOfWeekName {
    case "Sunday", "Saturday":
        from = oneDayEarlierString
        to = lastOpenDayString
    case "Monday":
        let lastThursday = dateFormatter.string(from: calendar.date(byAdding: .day, value: -4, to: today)!)
        let lastFriday = dateFormatter.string(from: calendar.date(byAdding: .day, value: -3, to: today)!)
        from = lastThursday
        to = lastFriday
    default:
        let todayString = dateFormatter.string(from: today)
        if isMarketOpen() {
            from = lastOpenDayString
            to = todayString
        } else {
            from = oneDayEarlierString
            to = lastOpenDayString
        }
    }

    return (from, to)
}


private func getLastOpenDate() -> Date? {
    let calendar = Calendar.current
    let today = Date()
    let dayOfWeek = calendar.component(.weekday, from: today)
    
    // Day of the week for Calendar: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    switch dayOfWeek {
    case 1: // Sunday
        // If today is Sunday, last open day was Friday
        return calendar.date(byAdding: .day, value: -2, to: today)
    case 2: // Monday
        // If today is Monday, last open day was also Friday
        return calendar.date(byAdding: .day, value: -3, to: today)
    case 7: // Saturday
        // If today is Saturday, last open day was Friday
        return calendar.date(byAdding: .day, value: -1, to: today)
    default:
        // Other days: just return the previous day
        return calendar.date(byAdding: .day, value: -1, to: today)
    }
}

/// Determines if the NYSE market is currently open
func isMarketOpen() -> Bool {
    let now = Date()
    let timeZone = TimeZone(identifier: "America/New_York")!
    var calendar = Calendar.current
    calendar.timeZone = timeZone

    let components = calendar.dateComponents([.hour, .minute, .weekday], from: now)
    
    guard let hour = components.hour, let minute = components.minute, let weekday = components.weekday else {
        return false
    }

    // Check if today is a weekday (Monday = 2, ..., Friday = 6)
    if weekday >= 2 && weekday <= 6 {
        // Market hours from 9:30 AM to 4:00 PM Eastern Time
        if (hour > 9 || (hour == 9 && minute >= 30)) && (hour < 16) {
            return true
        }
    }

    return false
}

