import SpriteKit
import AVFoundation


public class Scene: SKScene {
    
    //constants that determine the nodes behavior on the scene
    public let maximumDistance = CGFloat(120)
    public let bounce: CGFloat = 0.5
    public let friction: CGFloat = 1.01
    
    //scene elements initialization
    public var childNodes: [Node] = []
    public var selectedNode = Node(at: CGPoint.zero, isRoot: true, verseIndex: 0)
    public let blackHole = SKShapeNode.init(circleOfRadius: 200)
    public var links: [Link] = []
    public var limit = CGSize()
    public var closeNode: Node?
    public var didSelect = false
    public var verseIndex: Int = 0
    public var alreadyAdded: Bool = false
    
    
    public override init(size: CGSize) {
        super.init(size: size)
        
        //make the sound be louder at the center
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        let myListener = SKShapeNode.init(circleOfRadius: 0)
        myListener.position = center
        self.addChild(myListener)
        listener = myListener

        //set the place where nodes are destroyed
        blackHole.fillColor = .black
        blackHole.position = CGPoint(x: self.frame.width/2, y: -150)
        self.addChild(blackHole)
        
        self.limit = size
        self.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: touches handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        let touch = touches.first!
        let location = touch.location(in: self)

        //some conditions have to be tested if there are child nodes on the scene, else, just create a new node
        guard childNodes.count != 0 else {
            addNode(at: location)
            return
        }

        //for every node on the scene
        for node in childNodes {
            //check if the touch is a selection
            if node.paddingCircle.contains(location) {
                didSelect = true
                selectedNode = node
                selectedNode.reverb()
            }
        }
        
        //it will only continue to add a new node if the touch did not select anything
        guard !didSelect else {return}
        
        for node in childNodes {
            //get the distance between the location and the node
            let dx = node.circle.position.x - location.x
            let dy = node.circle.position.y - location.y
            let dist = sqrt(dx*dx + dy*dy)
            
            //if it's smaller than the maximum distance, add a new node and make a connection (edge)
            if dist < maximumDistance {
                closeNode = node
                addNode(at: location)
                alreadyAdded = true
                closeNode = nil
            }
        }

        guard !alreadyAdded else {
            alreadyAdded = false
            return
        }
        addNode(at: location)
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard didSelect else {return}
        let touch = touches.first!
        let location = touch.location(in: self)
        selectedNode.circle.position = location
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didSelect = false
        guard blackHole.contains(touches.first!.location(in: self)) else {
            return
        }
        selectedNode.remove()
    }
    
    public func addNode(at location: CGPoint) {
        let newNode: Node
        if closeNode == nil {
            verseIndex += 1
            if verseIndex == 4 {verseIndex = 0}
            newNode = Node(at: location, verseIndex: verseIndex)
        } else {
            newNode = Node(at: location, isRoot: false, verseIndex: closeNode!.verseIndex)
            addLink(node1: closeNode!, node2: newNode)
        }
        childNodes.append(newNode)
        self.addChild(newNode.circle)
        self.addChild(newNode.paddingCircle)
        newNode.reverb()
    }
    
    public func addLink(node1: Node, node2: Node) {
        let link = Link(node1: node1, node2: node2)
        closeNode?.childNodes.append(node2)
        links.append(link)
    }
    
    func reverb() {
        self.removeAllActions()
        let trees = childNodes.filter { $0.isRoot == true }
        let tree = trees[Int(arc4random_uniform(UInt32(trees.count)))]
        tree.reverb()
    }
    
    //called every instant, provide the organic-like movements
    public override func update(_ currentTime: TimeInterval) {
        updateNodes()
        updateEdges()
    }
    
    public func updateNodes() {
        for node in childNodes {
            guard !blackHole.contains(node.circle.position) else {
                node.remove()
                return
            }
            //speed per axis
            let vx = (node.circle.position.x - node.previousPosition.x) / friction
            let vy = (node.circle.position.y - node.previousPosition.y) / friction
            
            //update position acording to the speed and the direction
            node.previousPosition = node.circle.position
            node.circle.position.x += vx
            node.circle.position.y += vy
            
            //when the node hits one of the "walls", change the direction and decrease the speed
            if node.circle.position.x > self.limit.width {
                node.circle.position.x = self.limit.width
                node.previousPosition.x = node.circle.position.x + vx * bounce
            }
            if node.circle.position.x < 0 {
                node.circle.position.x = 0
                node.previousPosition.x = node.circle.position.x + vx * bounce
            }
            if node.circle.position.y > self.limit.height {
                node.circle.position.y = self.limit.height
                node.previousPosition.y = node.circle.position.y + vy * bounce
            }
            if node.circle.position.y < 0 {
                node.circle.position.y = 0
                node.previousPosition.y = node.circle.position.y + vy * bounce
            }
            
            //update padding circle
            node.paddingCircle.position = node.circle.position
        }
    }
    
    public func updateEdges() {
        for link in links {
            
            //calculates the current distance using the pythagorean theorem
            let dx = link.node1.circle.position.x - link.node2.circle.position.x
            let dy = link.node1.circle.position.y - link.node2.circle.position.y
            let currentDistance = sqrt(dx*dx + dy*dy)
            
            let oldDistance = link.length
            let difference = oldDistance - currentDistance
            let fraction = difference/currentDistance/2
            let offsetx = dx * fraction
            let offsety = dy * fraction
            
            //bounce
            link.node1.circle.position.x += offsetx/4
            link.node1.circle.position.y += offsety/4
            link.node2.circle.position.x -= offsetx/4
            link.node2.circle.position.y -= offsety/4
            
        }
    }

}




