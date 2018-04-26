
/*:
 # Reverb
 
 Melodies, colors and graphs mixed together as a single interactive experience. This playground is an experiment of what music running through data structures looks and sounds like.
 
 Tap the screen to start!
 
 - Experiment:
    - If you tap on a node, the music will reverb through its child nodes, than the child nodes of the child nodes, and so on.
    - Proximity has an effect, distance has another
    - You can destroy nodes using the black hole
    - The more nodes on the scene, the greater is the reverb
 */

//#-hidden-code
import UIKit
import SpriteKit
import PlaygroundSupport

let view = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
let scene = Scene(size: CGSize(width: 1024, height: 768))
view.presentScene(scene)
scene.scaleMode = .aspectFill

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
//#-end-hidden-code
