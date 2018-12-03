//
//  aiMesh + makeIndicesGeometryElement.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiMesh {

    /// Creates a scenekit geometry element describing how vertices connect to define
    /// a three-dimensional object, or geometry for the specified mesh of a node.
    ///
    /// - Parameters:
    ///   - indexOffset: The total number of indices for the previous meshes.
    ///   - numberOfFaces: The number of faces in the geometry of the mesh.
    /// - Returns: A new geometry element object.
    public func makeIndicesGeometryElement(with indexOffset: Int,
                                           numberOfFaces: Int) -> SCNGeometryElement? {
        var indicesCounter: Int = 0
        let nIndices = getNumberOfFaceIndeces()
        let scnIndices = UnsafeMutablePointer<CShort>.allocate(capacity: nIndices)
        defer { scnIndices.deallocate() }
        for i in 0 ..< mNumFaces {
            let aiFace = mFaces[Int(i)]
            // We ignore faces which are not triangulated.
            if aiFace.mNumIndices != 3 {
                return nil
            }
            
            let indecesCount = Int(aiFace.mNumIndices)
            let faceIndeces = Array(UnsafeBufferPointer(start: aiFace.mIndices,
                                                        count: indecesCount))
            faceIndeces.forEach {
                // "Thread 1: Fatal error: Not enough bits to represent a signed value" fix.
                let indexOffset = Int64(indexOffset)
                let aiFace = Int64($0)
                let sumResult = Int16(indexOffset + aiFace)
                
                scnIndices[indicesCounter] = sumResult
                indicesCounter += 1
            }
        }
        
        let dataLength = nIndices * MemoryLayout<CShort>.size
        let indicesData = NSData(bytes: scnIndices,
                                 length: dataLength) as Data
        let bytesPerIndex = MemoryLayout<CShort>.size
        let indices = SCNGeometryElement(data: indicesData,
                                         primitiveType: .triangles,
                                         primitiveCount: numberOfFaces,
                                         bytesPerIndex: bytesPerIndex)
        return indices
    }
    

}
