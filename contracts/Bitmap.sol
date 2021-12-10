// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct XY {
    int256 x;
    int256 y;
}

struct RGB {
    bytes1 red;
    bytes1 green;
    bytes1 blue;
}

struct Bitmap {
    bytes data;
    uint256 lineSize;
}

library BitmapLib {
    uint256 constant headerSize = 54;
    uint256 constant pixelSize = 3;

    function init(Bitmap memory bitmap, XY memory size) internal pure {
        uint256 linePadding = (uint256(size.x) * pixelSize) % 4 == 0
            ? 0
            : 4 - ((uint256(size.x) * pixelSize) % 4);
        bitmap.lineSize = uint256(size.x) * pixelSize + linePadding;
        uint256 bodySize = bitmap.lineSize * uint256(size.y);
        uint256 fileSize = headerSize + bodySize;
        bitmap.data = new bytes(fileSize);

        bitmap.data[0] = 0x42;
        bitmap.data[1] = 0x4d;
        setUint32(bitmap, 2, uint32(fileSize));
        setUint32(bitmap, 10, uint32(headerSize));
        setUint32(bitmap, 14, 40);
        setUint32(bitmap, 18, uint32(int32(size.x)));
        setUint32(bitmap, 22, uint32(int32(size.y)));
        setUint16(bitmap, 26, 1);
        setUint16(bitmap, 28, uint16(pixelSize * 8));
        setUint32(bitmap, 34, uint32(bodySize));
    }

    function setPixel(
        Bitmap memory bitmap,
        XY memory position,
        RGB memory pixel
    ) internal pure {
        uint256 index = headerSize +
            uint256(position.y) *
            bitmap.lineSize +
            uint256(position.x) *
            pixelSize;
        bitmap.data[index] = pixel.blue;
        bitmap.data[index + 1] = pixel.green;
        bitmap.data[index + 2] = pixel.red;
    }

    function setBody(Bitmap memory bitmap, bytes memory body) internal pure {
        uint256 bodyLength = body.length;
        require(
            bitmap.data.length == headerSize + bodyLength,
            "invalid body size"
        );
        for (uint256 i = 0; i < bodyLength; i++) {
            bitmap.data[headerSize + i] = body[i];
        }
    }

    function setUint32(
        Bitmap memory bitmap,
        uint256 offset,
        uint32 value
    ) private pure {
        for (uint256 i = 0; i < 4; i++) {
            bitmap.data[offset + i] = bytes1(uint8(value / (2**(8 * i))));
        }
    }

    function setUint16(
        Bitmap memory bitmap,
        uint256 offset,
        uint16 value
    ) private pure {
        for (uint256 i = 0; i < 2; i++) {
            bitmap.data[offset + i] = bytes1(uint8(value / (2**(8 * i))));
        }
    }
}
