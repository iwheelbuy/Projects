import CatcherObjc

private enum Result<T> {

   case error(Swift.Error)
   case exception(NSException, file: String, line: Int)
   case undefined
   case value(T)

   func final() throws -> T {
      switch self {
      case .error(let error):
         throw error
      case .exception(let exception, file: let file, line: let line):
         throw NSError(domain: file, code: line, userInfo: ["NSException": exception])
      case .undefined:
         Swift.assertionFailure()
         throw NSError()
      case .value(let value):
         return value
      }
   }
}

@discardableResult
public func safely<T>(_ block: () throws -> T, file: String = #file, line: Int = #line) throws -> T {
   var result = Result<T>.undefined
   Safely.try({
      do {
         let value = try block()
         result = .value(value)
      } catch {
         result = .error(error)
      }
   }, catch: { exception in
      result = .exception(exception, file: file, line: line)
   })
   return try result.final()
}
