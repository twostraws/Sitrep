import SwiftUI

/// This is an example enum
enum Direction {
    case north
    case south(let associatedValue: Bool)
    case east, west
}
