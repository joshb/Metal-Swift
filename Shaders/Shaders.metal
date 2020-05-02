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

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
	float3 position [[attribute(0)]];
	float3 tangent [[attribute(1)]];
	float3 bitangent [[attribute(2)]];
	float3 normal [[attribute(3)]];
	float2 texCoords [[attribute(4)]];
} Vertex;

typedef struct {
	float4 position [[position]];
	float2 texCoords;
	float3 cameraVector;
	float3 lightVector1, lightVector2, lightVector3;
} Fragment;

typedef struct {
	float3 diffuse;
	float3 specular;
} Lighting;

vertex Fragment vertexShader(Vertex in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
	auto tangentSpace = matrix_float3x3(in.tangent, in.bitangent, in.normal);

	Fragment out;
	out.position = (uniforms.projectionMatrix * uniforms.modelviewMatrix) * float4(in.position, 1.0);
	out.texCoords = in.texCoords;
	out.cameraVector = (uniforms.cameraPosition - in.position) * tangentSpace;
	out.lightVector1 = (uniforms.lightPositions[0] - in.position.xyz) * tangentSpace;
	out.lightVector2 = (uniforms.lightPositions[1] - in.position.xyz) * tangentSpace;
	out.lightVector3 = (uniforms.lightPositions[2] - in.position.xyz) * tangentSpace;
	return out;
}

Lighting calculateLighting(float3 normal, float3 cameraDir, float3 lightVector, float3 lightColor) {
	const float maxDist = 2.5;
	const float maxDistSquared = maxDist * maxDist;
	Lighting out;

	// calculate distance between 0.0 and 1.0
	float dist = min(dot(lightVector, lightVector), maxDistSquared) / maxDistSquared;
	float distFactor = 1.0 - dist;

	// diffuse
	float3 lightDir = normalize(lightVector);
	float diffuseDot = dot(normal, lightDir);
	out.diffuse = lightColor * clamp(diffuseDot, 0.0, 1.0) * distFactor;

	// specular
	float3 halfAngle = normalize(cameraDir + lightDir);
	float3 specularColor = min(lightColor + 0.5, 1.0);
	float specularDot = dot(normal, halfAngle);
	out.specular = specularColor * pow(clamp(specularDot, 0.0, 1.0), 16.0) * distFactor;

	return out;
}

Lighting addLighting(Lighting l1, Lighting l2) {
	Lighting tmp;
	tmp.diffuse = l1.diffuse + l2.diffuse;
	tmp.specular = l1.specular + l2.specular;
	return tmp;
}

fragment float4 fragmentShader(Fragment in [[stage_in]], texture2d<float> normalmap [[texture(0)]], constant Uniforms &uniforms [[buffer(1)]]) {
	constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

	// get the fragment normal and camera direction
	float3 fragmentNormal = normalmap.sample(colorSampler, in.texCoords).xyz;
	float3 normal = normalize(fragmentNormal);
	float3 cameraDir = normalize(in.cameraVector);

	auto lighting = calculateLighting(normal, cameraDir, in.lightVector1, uniforms.lightColors[0]);
	lighting = addLighting(lighting, calculateLighting(normal, cameraDir, in.lightVector2, uniforms.lightColors[1]));
	lighting = addLighting(lighting, calculateLighting(normal, cameraDir, in.lightVector3, uniforms.lightColors[2]));
	return float4(clamp(lighting.diffuse + lighting.specular, 0.0, 1.0), 1.0);
}

