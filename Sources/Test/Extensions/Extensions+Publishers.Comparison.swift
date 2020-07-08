import Combine

public extension Publishers.Comparison where Upstream.Output: Comparable {

   static func min(upstream: Upstream) -> Self {
      return Self(upstream: upstream, areInIncreasingOrder: { $0 < $1 })
   }

   static func max(upstream: Upstream) -> Self {
      return Self(upstream: upstream, areInIncreasingOrder: { $0 > $1 })
   }
}
