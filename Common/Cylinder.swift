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

class Cylinder: Mesh {
	final var divisions: Int
	private var _vertices: [MeshVertex]?

	init(divisions: Int) {
		self.divisions = divisions
	}

	var primitiveType: MTLPrimitiveType {
		return .triangleStrip
	}

	var vertices: [MeshVertex] {
		if let vertices = _vertices {
			return vertices
		}

		let divisionsf = Float(divisions)
		var vertices = [MeshVertex]()
		for i in 0...divisions {
			let r1 = ((Float.pi * 2.0) / divisionsf) * Float(i)
			let r2 = r1 + Float.pi / 2.0

			let c1 = cosf(r1)
			let s1 = sinf(r1)
			let c2 = cosf(r2)
			let s2 = sinf(r2)

			vertices.append(MeshVertex(position: Vector3(x: c1, y: 1.0, z: -s1),
			                           tangent: Vector3(x: c2, y: 0.0, z: -s2),
			                           bitangent: Vector3(x: 0.0, y: 1.0, z: 0.0),
			                           normal: Vector3(x: c1, y: 0.0, z: -s1),
									   texCoords: Vector2(x: 1.0 / divisionsf * Float(i) * 1.0, y: 0.0)))
			vertices.append(MeshVertex(position: Vector3(x: c1, y: -1.0, z: -s1),
			                           tangent: Vector3(x: c2, y: 0.0, z: -s2),
			                           bitangent: Vector3(x: 0.0, y: 1.0, z: 0.0),
			                           normal: Vector3(x: c1, y: 0.0, z: -s1),
			                           texCoords: Vector2(x: 1.0 / divisionsf * Float(i) * 1.0, y: 1.0)))
		}

		_vertices = vertices
		return vertices
	}
}
