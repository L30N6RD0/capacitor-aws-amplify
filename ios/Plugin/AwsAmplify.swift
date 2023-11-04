import Foundation

@objc public class AwsAmplify: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
