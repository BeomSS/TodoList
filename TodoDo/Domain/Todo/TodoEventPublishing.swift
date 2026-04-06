import Foundation

/// TODO 도메인 이벤트 발행 계약입니다.
/// 기본 앱은 no-op 구현을 사용하고, 필요 시 분석/로그/동기화 구현으로 교체할 수 있습니다.
public protocol TodoEventPublishing {
    /// 도메인 이벤트를 발행합니다.
    /// - Parameter event: 발행할 이벤트입니다.
    func publish(_ event: TodoEvent)
}
