import Foundation

/// This is an example struct
struct ExampleStruct {
    let usernameProperty: String
    let userAgeProperty: Int

    /// This is a static method with two parameters
    static func someStaticMethod(param1: String, param2: String) -> Int {
        return 5
    }

    func exampleMethodInStruct() {

    }

    func throwingMethodInStruct() throws {

    }

    /*
     This method rethrows
     */
    func rethrowingMethodInStruct() rethrows {

    }
}
