import CatcherObjc
@discardableResult
public func safely<T>(_ block: () throws -> T) throws -> T {
    var value: T?
    var error: Error!
    CatcherInterface.try({
        do {
            value = try block()
        } catch let _error {
            error = _error
        }
    }, catch: { (exception: NSException) in
        let description = "\(exception)"
        error = NSError(domain: "NSException", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
    })
    switch value {
    case .some(let value):
        return value
    case .none:
        throw error
    }
}
