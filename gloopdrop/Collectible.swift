//
//  Collectible.swift
//  gloopdrop
//
//  Created by Evgenii Ryshkov on 24.10.2021.
//

import Foundation
import SpriteKit

enum CollectibleType: String {
    case none
    case gloop
}

class Collectible: SKSpriteNode {
    // MARK: - PROPERTIES
    private var collectibleType: CollectibleType = .none

    // MARK: - INIT
    init(collectibleType: CollectibleType) {
        var texture: SKTexture!
        self.collectibleType = collectibleType

        switch self.collectibleType {
        case .gloop:
            texture = SKTexture(imageNamed: "gloop")
        case .none:
            break
        }

        super.init(texture: texture, color: SKColor.clear, size: texture.size())

        self.name = "co_\(collectibleType)"
        self.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.zPosition = Layer.collectible.rawValue
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0, y: -self.size.height))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.collectible
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.foreground
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drop(dropSpeed: TimeInterval, floorLevel: CGFloat) {
        let pos = CGPoint(x: position.x, y: floorLevel)

        let scaleX = SKAction.scaleX(to: 1, duration: 1)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1)
        let scale = SKAction.group([scaleX, scaleY])

        let appear = SKAction.fadeAlpha(to: 1, duration: dropSpeed)
        let moveAction = SKAction.move(to: pos, duration: dropSpeed)
        let actionSequence = SKAction.sequence([appear, scale, moveAction])

        self.scale(to: CGSize(width: 0.25, height: 1))
        self.run(actionSequence, withKey: "drop")
    }
}