import Foundation

protocol TestProtocol {
    var protocolProperty: String { get set }
    func protocolMethod() -> Int
}

protocol SecondProtocol {
    var secondProtocolProperty: String { get }
    var thirdProtocolProperty: Int { get }
    var fourthProtocolProperty: Bool { get }
}

protocol ThirdProtocol {
    func anotherProtocolMethod()
    func protocolMethod(with param: Int) -> String
}

protocol ProtocolWithInheritance: Codable {

}
