//
//  SpriteKitHelper.swift
//  gloopdrop
//
//  Created by Evgenii Ryshkov on 08.08.2021.
//

import Foundation
import SpriteKit

//MARK: -SPRITEKIT HELPERS

enum Layer: CGFloat {
    case background
    case foreground
    case player
    case collectible
    case ui
}

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b001
    static let collectible: UInt32 = 0b010
    static let foreground: UInt32 = 0b100
}

//MARK: - SPRITEKIT EXTENSIONS

extension SKSpriteNode {
    func loadTextures(atlas: String, prefix: String,
                      startsAt: Int, stopsAt: Int) -> [SKTexture] {
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startsAt...stopsAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        
        return textureArray
    }
    
    func startAnimation(textures: [SKTexture], speed: Double, name: String, count: Int, resize: Bool, restore: Bool) {
        guard (action(forKey: name) == nil) else {
            return
        }
        
        let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)
        
        switch count {
        case 0:
            let repeatAction = SKAction.repeatForever(animation)
            run(repeatAction, withKey: name)
        case 1:
            run(animation, withKey: name)
        default:
            let repeatAction = SKAction.repeat(animation, count: count)
            run(repeatAction, withKey: name)
        }
    }
}

extension SKScene {
    func viewTop() -> CGFloat{
        return convertPoint(fromView: CGPoint(x: 0, y: 0)).y
    }

    func viewBottom() -> CGFloat{
        guard let view = view else {return 0}
        return convertPoint(fromView: CGPoint(x: 0, y: view.bounds.size.height)).y
    }
}
