
/*
 
 A node contains:
 
 - Data structure properties:
 - A variable tha says
 - A list of child nodes if it is not a leaf
 
 - Physical properties:
 - The shape to be added to the scene as a cirle
 - The previous position of the circle
 - A larger and transparent circle used to the node selection
 
 - Visual and sound properties:
 - A color that represent the voice timbre it will emit
 - A sound child node that is relative to the color
 
 */

import SpriteKit
import UIKit
import AVFoundation

public let gray = UIColor.black.withAlphaComponent(0.05)

public class Node {
    
    //Data structure properties
    public var isRoot: Bool!
    public var childNodes: [Node] = []
    public var verseIndex: Int
    
    //Physical properties
    public var circle: SKShapeNode!
    public var previousPosition: CGPoint
    public var paddingCircle: SKShapeNode!
    
    //Visual and sound properties
    public var color: SKColor!
    public var audioNode: SKAudioNode
    public let verseColors = [SKColor.Verse.a, SKColor.Verse.b, SKColor.Verse.c, SKColor.Verse.d]
    public let dict = [
        SKColor.Verse.a: "lo-a.m4a",
        SKColor.Verse.b: "lo-b.m4a",
        SKColor.Verse.c: "lo-c.m4a",
        SKColor.Verse.d: "lo-d.m4a",
        gray: "percussao1.m4a",
        ]
    
    
    public init(at touch: CGPoint, isRoot: Bool = true, verseIndex: Int) {
        
        self.isRoot = isRoot
        self.verseIndex = verseIndex
        
        //visual settings of the circle
        let color = verseColors[Int(arc4random_uniform(UInt32(verseColors.count)))]
        let radius = isRoot ? 20 : CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (40 - 5) + 5
        circle = SKShapeNode(circleOfRadius: CGFloat(radius))
        circle.fillColor = isRoot ? gray : color
        circle.strokeColor = isRoot ? color : .white
        circle.lineWidth = isRoot ? 6 : 1
        
        //place the circle and it's selectable area at the touch position
        circle.position = CGPoint(x: touch.x, y: touch.y)
        paddingCircle = SKShapeNode(circleOfRadius: max(radius, 40))
        paddingCircle.fillColor = UIColor.clear
        paddingCircle.lineWidth = 0
        paddingCircle.position = circle.position
        
        //get a random file that corresponds to the color and the index
        var fileName: String
        if isRoot {
            fileName = dict[gray]!
        } else {
            fileName = dict[color]!
        }
        
        //set the audio node
        audioNode = SKAudioNode.init(fileNamed: fileName)
        audioNode.isPositional = true
        audioNode.autoplayLooped = isRoot ? true : false
        if !isRoot {audioNode.run(SKAction.changeVolume(to: 0.65, duration: 0))}
        circle.addChild(audioNode)
        
        //a "previous position" is forged so the shape enters in the scene as if it was continuing a movement
        let range = [-1.0, 1.0]
        let xrand = CGFloat(range[Int(arc4random_uniform(2))])
        let yrand = CGFloat(range[Int(arc4random_uniform(2))])
        previousPosition = CGPoint(x: circle.position.x + xrand, y: circle.position.y + yrand);
    
        if isRoot {reverb()}
    }
    
    public func reverb() {
        
        //stop if it was already running
        audioNode.run(SKAction.stop())
        for node in childNodes {node.audioNode.run(SKAction.stop())}
        circle.removeAllActions()
        let interval = isRoot ? Double(1.3) : Double(1)
        
        //the visual beat
        if isRoot {
            circle.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.repeatForever(SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1 * interval),
                    SKAction.scale(to: 1, duration: 0.9 * interval)
                    ]))
                ]))
        } else {
            circle.run(SKAction.sequence([
                //the first scale is bigger
                SKAction.scale(to: 2.6, duration: 0.1 * interval/1.7),
                SKAction.scale(to: 1, duration: 0.9 * interval/1.7),
                //a softer scale while the melody lasts
                SKAction.repeat(SKAction.sequence([
                    SKAction.scale(to: 1.5, duration: 0.1 * interval/1.7),
                    SKAction.scale(to: 1, duration: 0.9 * interval/1.7)
                    ]), count: 7)
                ]))
        }

        //the sound beat
        audioNode.run(SKAction.play())

        //wait the beat to be concluded and than repeat for each child node
        DispatchQueue.main.asyncAfter(deadline: .now() + (isRoot ? 0 : 1.1*interval)) {
            for node in self.childNodes {node.reverb()}
        }
    }
    
    public func remove() {
        //visual removal
        let parent = self.circle.parent as! Scene
        parent.childNodes = parent.childNodes.filter{$0 !== self}
        circle.run(SKAction.scale(to: 0, duration: 3))
        paddingCircle.run(SKAction.scale(to: 0, duration: 3))
        audioNode.run(SKAction.changePlaybackRate(to: 0, duration: 3))
        audioNode.run(SKAction.changeVolume(to: 0, duration: 3))

        //actual removal
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.paddingCircle.removeFromParent()
            self.audioNode.removeFromParent()
            self.circle.removeFromParent()
        }

    }
    
}
