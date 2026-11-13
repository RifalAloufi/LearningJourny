//
//  WeekStrpView.swift
//  MyApp
//
//  Created by Rifal  on 30/05/1448 AH.
//
import SwiftUI

enum DayCellState {
    case none
    case learned
    case freezed
}

struct WeekDay: Identifiable {
    let date: Date
    var state: DayCellState
    var isToday: Bool

    var id: Date { date }
}

extension WeekDay {
    /// Builds the 7 days (Sunday → Saturday) of the week that contains `date`.
    /// `states` is keyed by start-of-day date; days not in the dictionary are `.none`.
    static func week(
        containing date: Date,
        states: [Date: DayCellState] = [:],
        calendar: Calendar = .current
    ) -> [WeekDay] {
        var cal = calendar
        cal.firstWeekday = 1 // Sunday, like the design

        guard let start = cal.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }

        return (0..<7).compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: offset, to: start) else { return nil }
            let key = cal.startOfDay(for: day)
            return WeekDay(
                date: key,
                state: states[key] ?? .none,
                isToday: cal.isDate(day, inSameDayAs: date)
            )
        }
    }
}

struct WeekStripView: View {
    let days: [WeekDay]

    private let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                VStack(spacing: 10) {
                    Text(letter(for: day.date))
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)

                    Text("\(calendar.component(.day, from: day.date))")
                        .font(.title3)
                        .foregroundColor(textColor(for: day))
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(backgroundColor(for: day)))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func letter(for date: Date) -> String {
        let symbols = calendar.veryShortWeekdaySymbols
        return symbols[calendar.component(.weekday, from: date) - 1]
    }

    private func textColor(for day: WeekDay) -> Color {
    
            switch day.state {
            case .learned: return .appOrange
            case .freezed: return .freezeBlue
            case .none:    return .white
            }
        }
    

    private func backgroundColor(for day: WeekDay) -> Color {
        switch day.state {
        case .learned: return Color.appOrange.opacity(0.18)
        case .freezed: return Color.freezeBlue.opacity(0.18)
        case .none:    return day.isToday ? .appOrange : .clear
        }
    }
}

#Preview {
    WeekStripView(days: WeekDay.week(containing: .now))
        .padding()
        .background(Color.black)
}
