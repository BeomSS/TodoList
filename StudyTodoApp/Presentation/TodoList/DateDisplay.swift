import Foundation

/// 화면 날짜 표시에 사용하는 포맷터 모음입니다.
enum DateDisplay {
    /// TODO 날짜/시간 표시 포맷터입니다.
    static let todoDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        return formatter
    }()
}
