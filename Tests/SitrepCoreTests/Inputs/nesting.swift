/*
    Copyright (c) Important Company
    This is a block comment.
*/
import Combine
import UIKit

/// Documentation comment before `ViewController`. This has multiple inheritances, plus a nested enum and class,
/// and the code has lots of spacing.
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// Documentation comment before TestEnum
    enum TestEnum {
        case firstInlineCase, secondInlineCase
        case thirdCase(wind: Int)
        case fourthCase
    }

    // Regular comment before InnerClass
    class InnerClass {

        // some comment

        // some comment

        // some comment

        // some comment

    }
}
