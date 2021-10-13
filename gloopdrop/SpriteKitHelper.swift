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
}
