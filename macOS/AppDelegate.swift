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

import Cocoa
import Metal
import MetalKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MTKViewDelegate {
    @IBOutlet weak var window: NSWindow!
    private var scene: Scene?

    private var view: MTKView {
        return window.contentView as! MTKView
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        view.device = device
        view.delegate = self
        view.depthStencilPixelFormat = .depth32Float
        view.clearDepth = 1.0

        guard let scene = Scene(device: device, colorPixelFormat: view.colorPixelFormat, depthStencilPixelFormat: view.depthStencilPixelFormat) else {
            print("Could not create scene")
            return
        }

        self.scene = scene
        mtkView(view, drawableSizeWillChange: view.drawableSize)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if let scene = self.scene {
            scene.drawingDimensions = Vector2(x: Float(size.width), y: Float(size.height))
        }
    }

    func draw(in view: MTKView) {
        if let scene = self.scene {
            scene.cycle(secondsElapsed: 1.0 / Float(view.preferredFramesPerSecond))
            scene.render(renderPassDescriptor: view.currentRenderPassDescriptor!, drawable: view.currentDrawable!)
        }
    }
}

