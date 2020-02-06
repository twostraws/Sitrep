import CoreImage
import MapKit

class ExampleClass3: Codable {
    let someProperty: String
    var someOtherProperty: Int = 5

    init(wom: String) {
        print("Woot")
    }

    func exampleMethodInClass() {
        var localVariable = "Fizz"
        let localConstant = "Buzz"
    }

    /// This is a class method with two parameters
    class func someClassMethod(param1: String, param2: String) -> Int {
        return 5
    }
}
