import Foundation
import CoreGraphics
import Unbox

/// Structure acting as a namespace for types describing positions
public struct Position<T: Number> {
    public typealias TwoDimensional = Position_2D<T>
    public typealias ThreeDimensional = Position_3D<T>
}

/// Structure describing a two-dimensional position
public struct Position_2D<T: Number>: Hashable, StringConvertible, CustomStringConvertible, CustomDebugStringConvertible, EmptyInitializable {
    public var hashValue: Int { return self.description.hashValue }
    public var description: String { return "\(self.x):\(self.y)" }
    public var debugDescription: String { return self.description }
    
    public var x: T
    public var y: T
    
    /// Initialize a value, nil = 0
    public init(x: T? = nil, y: T? = nil) {
        self.x = x ?? T(0)
        self.y = y ?? T(0)
    }
    
    /// Initialize an empty value
    public init() {
        self.init(x: nil, y: nil)
    }
    
    /// Return a new position by offsetting this position
    public func positionOffsetByX(x: T, y: T) -> Position_2D<T> {
        return Position_2D(x: (self.x + x) as T, y: (self.y + y) as T)
    }
    
    /// Return a new position by moving this position by 1 unit in a direction
    public func positionInDirection<D: DirectionType>(direction: D, coordinateSystem: CoordinateSystem = .OriginUpperLeft) -> Position_2D<T> {
        switch direction.toEightWayDirection() {
        case .Up:
            if coordinateSystem.incrementalVerticalDirection == .Up {
                return Position_2D(x: self.x, y: (self.y + 1) as T)
            } else {
                return Position_2D(x: self.x, y: (self.y - 1) as T)
            }
        case .UpRight:
            return self.positionInDirection(Direction.FourWay.Up).positionInDirection(Direction.FourWay.Right)
        case .Right:
            return Position_2D(x: (self.x + 1) as T, y: self.y)
        case .RightDown:
            return self.positionInDirection(Direction.FourWay.Right).positionInDirection(Direction.FourWay.Down)
        case .Down:
            if coordinateSystem.incrementalVerticalDirection == .Down {
                return Position_2D(x: self.x, y: (self.y + 1) as T)
            } else {
                return Position_2D(x: self.x, y: (self.y - 1) as T)
            }
        case .DownLeft:
            return self.positionInDirection(Direction.FourWay.Down).positionInDirection(Direction.FourWay.Left)
        case .Left:
            return Position_2D(x: (self.x - 1) as T, y: self.y)
        case .LeftUp:
            return self.positionInDirection(Direction.FourWay.Left).positionInDirection(Direction.FourWay.Up)
        }
    }
    
    /// Return an array of postions that are within the radius of this position, optionally ignoring a set of positions
    public func positionsWithinRadius(radius: Int, ignoredPositions: Set<Position_2D<T>> = [], includeSelf: Bool = false) -> [Position_2D<T>] {
        var positions = [Position_2D<T>]()
        
        self.forEachPositionWithinRadius(radius, ignoredPositions: ignoredPositions, includeSelf: includeSelf) {
            positions.append($0)
        }
        
        return positions
    }
    
    /// Run a closure on each position within a certain radius of this position
    public func forEachPositionWithinRadius(radius: Int, ignoredPositions: Set<Position_2D<T>> = [], includeSelf: Bool = false, closure: Position_2D<T> -> Void) {
        let selfX = self.x.toInt()
        let selfY = self.y.toInt()
        
        for x in (selfX - radius) ... (selfX + radius) {
            let yRange = radius - abs(selfX - x)
            
            for deltaY in -yRange ... yRange {
                let position = Position_2D(x: T(x), y: T(selfY + deltaY))
                
                if !includeSelf && position == self {
                    continue
                }
                
                if ignoredPositions.contains(position) {
                    continue
                }
                
                closure(position)
            }
        }
    }
    
    /// Return the direction (out of 4 ways) that another position is considered to be in
    public func directionToPosition(position: Position_2D<T>, coordinateSystem: CoordinateSystem = .OriginUpperLeft) -> Direction.FourWay? {
        if self == position {
            return nil
        }
        
        let selfX = self.x.toDouble()
        let selfY = self.y.toDouble()
        let positionX = position.x.toDouble()
        let positionY = position.y.toDouble()
        
        if abs(selfX - positionX) > abs(selfY - positionY) {
            if positionX > selfX {
                return .Right
            } else {
                return .Left
            }
        } else {
            let incrementalDirection = coordinateSystem.incrementalVerticalDirection
            
            if positionY > selfY {
                return incrementalDirection
            } else {
                return incrementalDirection.oppositeDirection()
            }
        }
    }
    
    /// Conver this position into a CGPoint with equivalent x & y values
    public func toCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
    
    /// Convert this position into a CGPoint with a certain Position:CGPoint ratio
    public func toCGPointWithRatio(ratio: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(self.x) * ratio, y: CGFloat(self.y) * ratio)
    }
    
    public func toString() -> String {
        return self.description
    }
}

/// Extension making 2D Positions usable as Unboxable keys
extension Position_2D: UnboxableKey {
    public static func transformUnboxedKey(unboxedKey: String) -> Position_2D<T>? {
        let parts = unboxedKey.componentsSeparatedByString(":")
        
        guard let first = parts.first, last = parts.last where parts.count == 2 else {
            return nil
        }
        
        guard let x = T(string: first), y = T(string: last) else {
            return nil
        }
        
        return self.init(x: x, y: y)
    }
}

/// Structure describing a three-dimensional position
public struct Position_3D<T: Number>: Hashable, EmptyInitializable {
    public var hashValue: Int { return "\(self.x):\(self.y):\(self.z)".hashValue }
    
    public var x: T
    public var y: T
    public var z: T
    
    /// Initialize a value, nil = 0
    public init(x: T? = nil, y: T? = nil, z: T? = nil) {
        self.x = x ?? T(0)
        self.y = y ?? T(0)
        self.z = z ?? T(0)
    }
    
    /// Initialize an empty value
    public init() {
        self.init(x: nil, y: nil, z: nil)
    }
}

/// Extension making 3D Positions usable as Unboxable keys
extension Position_3D: UnboxableKey {
    public static func transformUnboxedKey(unboxedKey: String) -> Position_3D<T>? {
        let parts = unboxedKey.componentsSeparatedByString(":")
        
        guard let first = parts.first, middle = parts.valueAtIndex(1), last = parts.last where parts.count == 3 else {
            return nil
        }
        
        guard let x = T(string: first), y = T(string: middle), z = T(string: last) else {
            return nil
        }
        
        return self.init(x: x, y: y, z: z)
    }
}

// Equatable support for Position_2D
public func ==<T: Number>(lhs: Position_2D<T>, rhs: Position_2D<T>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// Equatable support for Position_3D
public func ==<T: Number>(lhs: Position_3D<T>, rhs: Position_3D<T>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
