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

/// Represents a 3D vector.
struct Vector3 {
	var x: Float = 0.0
	var y: Float = 0.0
	var z: Float = 0.0

	var simd: vector_float3 {
		return vector_float3(x, y, z)
	}

	var length: Float {
		return sqrtf(x*x + y*y + z*z)
	}

	var normalized: Vector3 {
		let len = length
		return Vector3(x: x / len, y: y / len, z: z / len)
	}
}

func + (left: Vector3, right: Vector3) -> Vector3 {
	return Vector3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: Vector3, right: Vector3) -> Vector3 {
	return Vector3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

func * (left: Vector3, right: Vector3) -> Vector3 {
	return Vector3(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
}

func + (left: Vector3, right: Float) -> Vector3 {
	return Vector3(x: left.x * right, y: left.y * right, z: left.z * right)
}
