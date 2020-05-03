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

import Metal
import MetalKit

class Scene {
    private final var device: MTLDevice

    private final var commandQueue: MTLCommandQueue!
    private final var pipelineState: MTLRenderPipelineState!

    private final var mesh: Mesh!
    private final var vertexBuffer: MTLBuffer!

    private final var textureLoader: MTKTextureLoader!
    private final var normalmapTexture: MTLTexture!

    private final var uniforms: UnsafeMutablePointer<Uniforms>!
    private final var uniformBuffer: MTLBuffer!

    init?(device: MTLDevice, colorPixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat) {
        self.device = device

        guard let library = device.makeDefaultLibrary() else {
            print("Default library not found")
            return nil
        }

        mesh = Cylinder(divisions: 30)
        vertexBuffer = mesh.makeBuffer(device: device)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        descriptor.vertexDescriptor = mesh.vertexDescriptor
        descriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        descriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Could not make render pipeline state")
            return nil
        }

        textureLoader = MTKTextureLoader(device: device)
        let textureOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        do {
            normalmapTexture = try textureLoader.newTexture(name: "normalmap", scaleFactor: 1.0, bundle: nil, options: textureOptions)
        } catch {
            print("Could not load normalmap texture")
            return nil
        }

        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        uniforms = UnsafeMutableRawPointer(uniformBuffer.contents()).bindMemory(to:Uniforms.self, capacity:1)
        uniforms[0].lightColors = (
            Vector3(x: 1.0, y: 0.0, z: 0.0).simd,
            Vector3(x: 0.0, y: 1.0, z: 0.0).simd,
            Vector3(x: 0.0, y: 0.0, z: 1.0).simd
        )

        commandQueue = device.makeCommandQueue()
    }

    private var _drawingDimensions = Vector2()
    var drawingDimensions: Vector2 {
        get {
            return _drawingDimensions
        }
        set {
            _drawingDimensions = newValue
            let aspectRatio = newValue.x / newValue.y
            uniforms[0].projectionMatrix = perspectiveMatrix(fov: Float.pi / 2.0, aspect: aspectRatio, near: 0.1, far: 200.0)
        }
    }

    func render(renderPassDescriptor: MTLRenderPassDescriptor, drawable: MTLDrawable) {
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                // Enable depth testing.
                let descriptor = MTLDepthStencilDescriptor()
                descriptor.isDepthWriteEnabled = true
                descriptor.depthCompareFunction = .lessEqual
                let state = device.makeDepthStencilState(descriptor: descriptor)
                encoder.setDepthStencilState(state)

                // Render the cylinder mesh.
                encoder.setRenderPipelineState(pipelineState)
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
                encoder.setFragmentTexture(normalmapTexture, index: 0)
                encoder.drawPrimitives(type: mesh.primitiveType, vertexStart: 0, vertexCount: mesh.vertices.count)
                encoder.endEncoding()
            }

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }

    private var cameraRotation: Float = 0.0
    private var cameraPosition = Vector3(x: 0.0, y: 0.0, z: 4.0)
    private var lightRotation: Float = 0.0
    func cycle(secondsElapsed: Float) {
        // Update the camera position.
        cameraRotation -= (Float.pi / 16.0) * secondsElapsed
        cameraPosition = Vector3(x: sinf(cameraRotation), y: 0.0, z: cosf(cameraRotation)) * 2.5
        uniforms[0].cameraPosition = cameraPosition.simd

        // Update the modelview matrix.
        let r = rotationMatrix(angle: cameraRotation, x: 0.0, y: -1.0, z: 0.0)
        let t = translationMatrix(x: -cameraPosition.x, y: -cameraPosition.y, z: -cameraPosition.z)
        uniforms[0].modelviewMatrix = r * t

        // Update the light positions.
        lightRotation += (Float.pi / 4.0) * secondsElapsed
        var lightPositions = [Vector3]()
        for i in 0..<NUM_LIGHTS {
            let radius: Float = 1.75
            let r = (((Float.pi * 2.0) / Float(NUM_LIGHTS)) * Float(i)) + lightRotation
            lightPositions.append(Vector3(x: cosf(r) * radius, y: cosf(r) * sinf(r), z: sinf(r) * radius))
        }
        uniforms[0].lightPositions = (lightPositions[0].simd, lightPositions[1].simd, lightPositions[2].simd)
    }
}

