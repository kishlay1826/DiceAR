//
//  ViewController.swift
//  DiceAR
//
//  Created by Kishlay Chhajer on 2020-08-21.
//  Copyright © 2020 Kishlay Chhajer. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
   
    }
    
    @IBAction func rollButton(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func clearDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = result.first {
                let dice = SCNScene(named: "art.scnassets/diceCollada.scn")!
                   if let node = dice.rootNode.childNode(withName: "Dice", recursively: true) {
                           node.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                                      y: hitResult.worldTransform.columns.3.y + node.boundingSphere.radius,
                                                      z: hitResult.worldTransform.columns.3.z)
                    diceArray.append(node)
                           sceneView.scene.rootNode.addChildNode(node)
                           sceneView.autoenablesDefaultLighting = true
                    rollOne(dice: node)
                       }
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
            rollOne(dice: dice)
                }
            }
    }
    
    func rollOne(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 4), y: 0, z: CGFloat(randomZ * 4), duration: 0.5))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let anchorPlane = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(anchorPlane.extent.x), height: CGFloat(anchorPlane.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: anchorPlane.center.x, y: 0, z: anchorPlane.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        }
    }

}
