import Foundation

/// 마감 알림 옵션 정의입니다.
/// rawValue는 "마감 몇 초 전"을 의미합니다.
enum TodoReminderOption: Int, CaseIterable, Identifiable {
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case thirtyMinutes = 1_800
    case oneHour = 3_600
    case twoHours = 7_200
    case oneDay = 86_400
    case twoDays = 172_800

    /// 식별자입니다.
    var id: Int { rawValue }

    /// UI에 노출할 한글 라벨입니다.
    var title: String {
        switch self {
        case .fiveMinutes: return "5분 전"
        case .tenMinutes: return "10분 전"
        case .fifteenMinutes: return "15분 전"
        case .thirtyMinutes: return "30분 전"
        case .oneHour: return "1시간 전"
        case .twoHours: return "2시간 전"
        case .oneDay: return "1일 전"
        case .twoDays: return "2일 전"
        }
    }
}
