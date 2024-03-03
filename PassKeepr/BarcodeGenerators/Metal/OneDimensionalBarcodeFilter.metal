//
//  OneDimensionalBarcodeFilter.metal
//  PassKeepr
//
//  Created by Andrew Hanshaw on 2/3/24.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 OneDimensionalBarcodeFilter(float2 position, half4 currentColor, float width, device const void *dataBuffer, int dataBufferLength, device const void *numSegments, int numSegmentsLength) {
    device const uint8_t* dataMask = reinterpret_cast<device const uint8_t*>(dataBuffer);
    device const uint8_t* numberOfSegmentsInput = reinterpret_cast<device const uint8_t*>(numSegments);

    float segmentSize = width/float(numberOfSegmentsInput[0]);

    int currentSegment = int((position.x)/segmentSize);

    int currentByte = currentSegment / 8;
    int currentBit  = currentSegment % 8;

    return ((dataMask[currentByte] >> (7-currentBit)) & 0x1) ? half4(0,0,0,1) : half4(1,1,1,1);
}
