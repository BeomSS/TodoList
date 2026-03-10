import Foundation

/// 할 일 제목 정규화(트림/중복 공백 제거 등) 규칙입니다.
public struct TodoTitleNormalizer {
    /// 제목 정규화기를 생성합니다.
    public init() {}

    /// 사용자 입력 문자열을 저장 가능한 형태로 정규화합니다.
    /// - Parameter raw: 원본 입력 문자열입니다.
    /// - Returns: 줄바꿈/연속 공백이 정리된 문자열입니다.
    public func normalize(_ raw: String) -> String {
        // 줄바꿈/연속 공백을 단일 공백으로 압축합니다.
        let collapsed = raw
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")

        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
