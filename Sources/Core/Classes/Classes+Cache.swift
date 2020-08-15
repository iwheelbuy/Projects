import Foundation

open class Cache<K, V> where K: Hashable {

    private let cache = NSCache<__Key<K>, __Value<V>>()

    public init(countLimit: Int? = nil) {
        if let countLimit = countLimit {
            self.countLimit = countLimit
        }
    }

    public var countLimit: Int {
        get {
            return cache.countLimit
        }
        set(countLimit) {
            cache.countLimit = countLimit
        }
    }

    public subscript (key: K) -> V? {
        get {
            return cache.object(forKey: __Key(key))?.value
        }
        set(object) {
            switch object {
            case .some(let value):
                cache.setObject(__Value(value), forKey: __Key(key))
            case .none:
                cache.removeObject(forKey: __Key(key))
            }
        }
    }

    public func removeAllObjects() {
        cache.removeAllObjects()
    }
}

// MARK: -

private final class __Key<K>: NSObject where K: Hashable {

    private let key: K

    init(_ key: K) {
        self.key = key
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? __Key else {
            return false
        }
        return self.key == other.key
    }

    override var hash: Int {
        return self.key.hashValue
    }
}

// MARK: -

private final class __Value<V>: NSObject {

    let value: V

    init(_ value: V) {
        self.value = value
        super.init()
    }
}
