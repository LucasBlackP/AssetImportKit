//
//  aiNode + makeNormalGeometrySource.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    /**
     Creates a scenekit geometry source from the normals of the specified node.
     
     @param aiNode The assimp node.
     @param aiScene The assimp scene.
     @param nVertices The number of vertices in the meshes of the aiNode.
     @return A new geometry source whose semantic property is normal.
     */
    public func makeNormalGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnNormals = UnsafeMutablePointer<Float>.allocate(capacity: numberOfVertices * 3)
        defer { scnNormals.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshNormals = aiMesh.mNormals {
                print("Getting normals")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshNormals[vertexIndex]
                    scnNormals[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnNormals[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnNormals[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float>.size
        let data = NSData(bytes: scnNormals, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float>.size
        let dataStride = 3 * bytesPerComponent
        let normalSource = SCNGeometrySource(data: data,
                                             semantic: .normal,
                                             vectorCount: numberOfVertices,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: bytesPerComponent,
                                             dataOffset: 0,
                                             dataStride: dataStride)
        return normalSource
    }
    
}

