import CoreGraphics

/// SwiftKit extensions to CGPoint
public extension CGPoint {
    /// Return the distance (in form of a vector) between this point and another
    public func distanceToPoint(point: CGPoint) -> CGVector {
        return CGVector(dx: point.x - self.x, dy: point.y - self.y)
    }
    
    /// Return a new point by offsetting this point by a x and y value
    public func pointOffsetByX(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
    /// Return a new point by offsetting this point with a vector
    public func pointOffsetBy(vector: CGVector) -> CGPoint {
        return CGPoint(x: self.x + vector.dx, y: self.y + vector.dy)
    }
    
    /// Return a new point by multiplying this point's x and y values by a factor
    public func pointMultipliedByX(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * x, y: self.y * y)
    }
    
    /// Return a new point that is the result of moving this point a certain distance in a direction
    public func pointAtDistance<T: DirectionType>(distance: CGFloat, inDirection direction: T, coordinateSystem: CoordinateSystem, integral: Bool = true) -> CGPoint {
        var verticalDistance = distance * cos(direction.radianValue)
        
        if coordinateSystem.incrementalVerticalDirection == .Down {
            verticalDistance = -verticalDistance
        }
        
        let decimalCount = UInt(integral ? 0 : 3)
        
        return CGPoint(
            x: (self.x + distance * sin(direction.radianValue)).roundedValueWithDecimalCount(decimalCount),
            y: (self.y + verticalDistance).roundedValueWithDecimalCount(decimalCount)
        )
    }
    
    /// Return a new point by finding the closest point in a grid given a certain tile size, assuming a {0, 0} origo
    public func closestPointInGridWithTileSize(tileSize: CGSize) -> CGPoint {
        return CGPoint(
            x: round(self.x / tileSize.width) * tileSize.width,
            y: round(self.y / tileSize.height) * tileSize.height
        )
    }
}