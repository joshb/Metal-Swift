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

/// Represents a 4x4 matrix.
typealias Matrix4 = matrix_float4x4

/// Returns a new perspective projection matrix.
func perspectiveMatrix(fov: Float, aspect: Float, near: Float, far: Float) -> Matrix4 {
    let f = 1.0 / tanf(fov / 2.0)
    return Matrix4(columns: (
        SIMD4<Float>(f / aspect, 0.0, 0.0, 0.0),
        SIMD4<Float>(0.0, f, 0.0, 0.0),
        SIMD4<Float>(0.0, 0.0, (far + near) / (near - far), -1.0),
        SIMD4<Float>(0.0, 0.0, (2.0 * far * near) / (near - far), 0.0)
    ))
}

/// Returns a new translation matrix.
func translationMatrix(x: Float, y: Float, z: Float) -> Matrix4 {
    return Matrix4(columns: (
        SIMD4<Float>(1.0, 0.0, 0.0, 0.0),
        SIMD4<Float>(0.0, 1.0, 0.0, 0.0),
        SIMD4<Float>(0.0, 0.0, 1.0, 0.0),
        SIMD4<Float>(x, y, z, 1.0)
    ))
}

/// Returns a new rotation matrix.
func rotationMatrix(angle: Float, x: Float, y: Float, z: Float) -> Matrix4 {
    let c = cosf(angle)
    let ci = 1.0 - c
    let s = sinf(angle)

    let xy = x * y * ci
    let xz = x * z * ci
    let yz = y * z * ci
    let xs = x * s
    let ys = y * s
    let zs = z * s

    return matrix_float4x4(columns: (
        SIMD4<Float>(x * x * ci + c, xy + zs, xz - ys, 0.0),
        SIMD4<Float>(xy - xz, y * y * ci + c, yz + xs, 0.0),
        SIMD4<Float>(xz + ys, yz - xs, z * z * ci + c, 0.0),
        SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
    ))
}
