//
//  ViewController.swift
//  ScenePlacing-with-reset
//
//  Created by samdatashed on 02/06/2019.
//  Copyright © 2019 sambowenhughes. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var AddObjectButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration();
    var pos = -0.3;
    var currentPositionOfCamera = SCNVector3(0, 0, 0);
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
    
        self.sceneView.delegate = self;
        self.sceneView.session.run(configuration)
    }

//    Method used to place objects on screen
    @IBAction func AddObject(_ sender: Any) {
        let pane1 = SCNNode();
        pane1.geometry =  SCNBox(width: 0.2, height: 0.1, length: 0.1, chamferRadius: 0);
        pane1.geometry?.firstMaterial?.diffuse.contents = UIColor.purple;
        
        let pane2 = SCNNode();
        pane2.geometry =  SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0);
        pane2.geometry?.firstMaterial?.diffuse.contents = UIColor.orange;
        
        let pane3 = SCNNode();
        pane3.geometry =  SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0);
        pane3.geometry?.firstMaterial?.diffuse.contents = UIColor.white;
        
        pane1.position = currentPositionOfCamera;
        
        currentPositionOfCamera.x = currentPositionOfCamera.x + 0.2;
        pane2.position = currentPositionOfCamera;
        
        currentPositionOfCamera.x = currentPositionOfCamera.x + 0.3;
        pane3.position = currentPositionOfCamera;
        

        self.sceneView.scene.rootNode.addChildNode(pane1);
        self.sceneView.scene.rootNode.addChildNode(pane2);
        self.sceneView.scene.rootNode.addChildNode(pane3);
    }
    
//    Function used to reset the scene
    @IBAction func ResetScene(_ sender: Any) {
        self.sceneView.session.pause();
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _)in
            node.removeFromParentNode();
        }
        
        self.sceneView.session.run(configuration
            , options: [.resetTracking, .removeExistingAnchors])
    }
    
//    Function triggered every time the screen is rendered
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        currentPositionOfCamera = plus(left : orientation, right : location)
        
        DispatchQueue.main.async {
            let pointer = SCNNode();
            pointer.geometry = SCNSphere(radius: 0.02);
            pointer.name = "pointer";
            pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.white;
            pointer.position = self.currentPositionOfCamera;
            
            self.sceneView.scene.rootNode.enumerateChildNodes({ (node , _) in
                if(node.name == "pointer"){
                    node.removeFromParentNode();
                }
            });
            self.sceneView.scene.rootNode.addChildNode(pointer);
        }
        
    }
    
//    Override function which adds two vectors together
    func plus(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + left.y, left.z + right.z)
    }
}
