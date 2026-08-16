import SwiftUI

struct ForecastCardView: View {
    let time: String
    let icon: String
    let temp: Int
    let timezoneOffset: Int
    
    
    private var formattedTime:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = formatter.date(from: time) else { return time }

                let localDate = date.addingTimeInterval(TimeInterval(timezoneOffset))

                let output = DateFormatter()
                output.dateFormat = "HH:mm"
                output.timeZone = TimeZone(secondsFromGMT: 0)
                return output.string(from: localDate)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(formattedTime)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(.white)
            
            Text("\(temp)°")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 73, height: 100)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

