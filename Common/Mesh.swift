/*
 * Copyright (C) 2020 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import Metal

/// Represents a single vertex in a mesh.
struct MeshVertex {
	var position: Vector3
	var tangent: Vector3
	var bitangent: Vector3
	var normal: Vector3
	var texCoords: Vector2
}

protocol Mesh {
	var primitiveType: MTLPrimitiveType { get }
	var vertices: [MeshVertex] { get }
}

extension Mesh {
	func makeBuffer(device: MTLDevice) -> MTLBuffer? {
		let v = vertices
		return device.makeBuffer(bytes: v, length: MemoryLayout<MeshVertex>.size * v.count, options: [])
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let descriptor = MTLVertexDescriptor()
		for i in 0..<4 {
			descriptor.attributes[i].format = MTLVertexFormat.float3
			descriptor.attributes[i].offset = 12 * i
			descriptor.attributes[i].bufferIndex = 0
		}
		descriptor.attributes[4].format = MTLVertexFormat.float2
		descriptor.attributes[4].offset = 48
		descriptor.attributes[4].bufferIndex = 0
		descriptor.layouts[0].stride = MemoryLayout<MeshVertex>.size
		descriptor.layouts[0].stepRate = 1
		descriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
		return descriptor
	}
}
