import SwiftUI

/// Calendar page, pushed with navigation from the calendar icon on Activity.
/// Shows every month from the goal start until now, with Learned / Freezed days.
struct LearningCalendarView: View {
    let goalStart: Date
    let states: [Date: DayCellState]
    let today: Date

    private var calendar: Calendar {
        var c = Calendar.current
        c.firstWeekday = 1 // Sunday, like the rest of the app
        return c
    }

    /// Every month: January of the goal's start year through 12 months ahead of today
    /// (so upcoming months of a new year are included).
    private var months: [Date] {
        let cal = calendar
        guard let first = cal.dateInterval(of: .year, for: min(goalStart, today))?.start,
              let thisMonth = cal.dateInterval(of: .month, for: today)?.start,
              let end = cal.date(byAdding: .month, value: 13, to: thisMonth) else { return [] }

        var result: [Date] = []
        var cursor = first
        while cursor < end {
            result.append(cursor)
            guard let next = cal.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    private var currentMonth: Date {
        calendar.dateInterval(of: .month, for: today)?.start ?? today
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Weekday letters
                HStack(spacing: 0) {
                    ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, letter in
                        Text(letter)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 28) {
                            ForEach(months, id: \.self) { month in
                                MonthGridView(
                                    month: month,
                                    states: states,
                                    today: today,
                                    calendar: calendar
                                )
                                .id(month)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                    }
                    .onAppear {
                        // Open on the current month; the other months are one scroll away.
                        DispatchQueue.main.async {
                            proxy.scrollTo(currentMonth, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

private struct MonthGridView: View {
    let month: Date
    let states: [Date: DayCellState]
    let today: Date
    let calendar: Calendar

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var title: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: month)
    }

    /// Leading blanks so the 1st lands on the right weekday, then every day.
    private var days: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.dateInterval(of: .month, for: month)?.start else { return [] }

        let offset = calendar.component(.weekday, from: first) - calendar.firstWeekday
        let lead = (offset + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: lead)
        for day in range {
            result.append(calendar.date(byAdding: .day, value: day - 1, to: first))
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let key = calendar.startOfDay(for: date)
        let state = states[key] ?? .none
        let isToday = calendar.isDate(date, inSameDayAs: today)

        let textColor: Color
        let background: Color

        switch state {
        case .learned:
            textColor = .appOrange
            background = Color.appOrange.opacity(0.18)
        case .freezed:
            textColor = .freezeBlue
            background = Color.freezeBlue.opacity(0.18)
        case .none:
            textColor = .white
            background = isToday ? .appOrange : .clear
        }

        return Text("\(calendar.component(.day, from: date))")
            .font(.title3)
            .foregroundColor(textColor)
            .frame(width: 44, height: 44)
            .background(Circle().fill(background))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    let cal = Calendar.current
    let today = Date()
    let start = cal.date(byAdding: .month, value: -2, to: today) ?? today
    let states: [Date: DayCellState] = [
        cal.startOfDay(for: today.addingTimeInterval(-86_400)): .learned,
        cal.startOfDay(for: today.addingTimeInterval(-2 * 86_400)): .freezed,
        cal.startOfDay(for: today.addingTimeInterval(-3 * 86_400)): .learned
    ]

    return NavigationStack {
        LearningCalendarView(goalStart: start, states: states, today: today)
    }
}
