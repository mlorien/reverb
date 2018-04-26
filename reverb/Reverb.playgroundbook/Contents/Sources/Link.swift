
import UIKit
import SpriteKit


// A link is what links two nodes on the screen
public class Link {
    
    public var node1: Node
    public var node2: Node
    public var length: CGFloat
    
    
    public init(node1: Node, node2: Node) {
        self.node1 = node1
        self.node2 = node2
        
        //calculate the distance using the pithagoryan theorem
        let dx = node1.circle.position.x - node2.circle.position.x
        let dy = node1.circle.position.y - node2.circle.position.y
        let dist = sqrt(dx*dx + dy*dy)
        
        //when a node is created from another one, if the distance between them is bigger than 90, bring them closer
        self.length = min(dist, 90)
    }
    
}
