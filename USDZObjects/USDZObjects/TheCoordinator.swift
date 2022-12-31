//
//  TheCoordinator.swift
//  USDZObjects
//
//  Created by Fady Eid on 12/28/22.
//

import Foundation
import ARKit
import RealityKit
import Combine

import os.log // LOG
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Fad Coordinator") // LOG

class MyCoordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var cancellable: AnyCancellable?
    var anchoredStateSubscriber: (any Cancellable)?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        logger.log("Got handleTap")
        
        guard let view = self.view else { return }
        let tapLocation = recognizer.location(in: view)
        logger.log("Got tapLocation")
        
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let anchor = AnchorEntity(raycastResult: result)
            
            cancellable = Entity.loadAsync(named: "robot")
                .append(ModelEntity.loadAsync(named: "car"))
                .collect()
                .sink { [weak self] loadCompletion in
                    if case let .failure(error) = loadCompletion {
                        print("Unable to load model \(error)")
                    }
                    self?.cancellable?.cancel()
                } receiveValue: { [weak self] entites in
                    
                    var x: Float = 0.0
                    
                    entites.forEach { entity in
                        entity.position = simd_make_float3(x, 0, 0)
                        anchor.addChild(entity)
                        x += 0.3
                    }
                    
                    self?.view?.scene.addAnchor(anchor)
                }
        }
    }
    
    func setupSceneObservers() {
        guard let view else { return }
        
        anchoredStateSubscriber = view.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self) { event in
            // When view.scene.addAnchor(anchor) is added to scene, then this func will be triggered
            if event.anchor.isActive {
                for entity in event.anchor.children {
                    for animations in entity.availableAnimations {
                        entity.playAnimation(animations.repeat())
                    }
                }
            }
        }
    }
}
