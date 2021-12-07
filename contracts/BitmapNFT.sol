// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";
import "./Bitmap.sol";

library RGBLib {
    function complementary(RGB memory pixel)
        internal
        pure
        returns (RGB memory)
    {
        uint256 red = uint256(uint8(pixel.red));
        uint256 green = uint256(uint8(pixel.green));
        uint256 blue = uint256(uint8(pixel.blue));
        uint256 max = red;
        uint256 min = red;
        if (green > max) {
            max = green;
        }
        if (green < min) {
            min = green;
        }
        if (blue > max) {
            max = blue;
        }
        if (blue < min) {
            min = blue;
        }
        return
            RGB(
                bytes1(uint8(max + min - red)),
                bytes1(uint8(max + min - green)),
                bytes1(uint8(max + min - blue))
            );
    }
}

library PositionLib {
    function add(
        XY memory position,
        int256 x,
        int256 y
    ) internal pure returns (XY memory) {
        return XY(position.x + x, position.y + y);
    }
}

struct PixelFactory {
    bytes32 data;
    bool random;
    int256 step;
    RGB from;
    RGB to;
}

library PixelFactoryLib {
    using RGBLib for RGB;

    function init(
        PixelFactory memory factory,
        bytes32 data,
        int256 step
    ) internal pure {
        factory.data = data;
        factory.step = step;
        factory.random = uint256(data) % 3 == 0;
        if (factory.random) {
            return;
        }
        factory.from = RGB(data[0], data[1], data[2]);
        uint248 toPattern = uint248(bytes31(data)) % 4;
        if (toPattern == 0) {
            factory.to = RGB(0, 0, 0);
        } else if (toPattern == 1) {
            factory.to = RGB(0xff, 0xff, 0xff);
        } else if (toPattern == 2) {
            factory.to = factory.from.complementary();
        } else {
            factory.to = RGB(data[3], data[4], data[5]);
        }
        if (uint240(bytes30(data)) % 2 == 0) {
            RGB memory tmp = factory.from;
            factory.from = factory.to;
            factory.to = tmp;
        }
    }

    function create(PixelFactory memory factory, int256 index)
        internal
        pure
        returns (RGB memory)
    {
        RGB memory pixel;
        if (factory.random) {
            pixel.blue = factory.data[(uint256(index) * 3) % 32];
            pixel.green = factory.data[(uint256(index) * 3 + 1) % 32];
            pixel.red = factory.data[(uint256(index) * 3 + 2) % 32];
            return pixel;
        }
        int256 blueDiff = ((int256(uint256(uint8(factory.to.blue))) -
            int256(uint256(uint8(factory.from.blue)))) * index) / factory.step;
        pixel.blue = bytes1(
            uint8(int8(int256(uint256(uint8(factory.from.blue))) + blueDiff))
        );
        int256 greenDiff = ((int256(uint256(uint8(factory.to.green))) -
            int256(uint256(uint8(factory.from.green)))) * index) / factory.step;
        pixel.green = bytes1(
            uint8(int8(int256(uint256(uint8(factory.from.green))) + greenDiff))
        );
        int256 redDiff = ((int256(uint256(uint8(factory.to.red))) -
            int256(uint256(uint8(factory.from.red)))) * index) / factory.step;
        pixel.red = bytes1(
            uint8(int8(int256(uint256(uint8(factory.from.red))) + redDiff))
        );
        return pixel;
    }
}

contract BitmapNFT is ERC721, Ownable {
    using BitmapLib for Bitmap;
    using PositionLib for XY;
    using PixelFactoryLib for PixelFactory;

    constructor() ERC721("BitmapNFT", "BNFT") {}

    function mint(uint256 tokenId) public {
        _mint(_msgSender(), tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getBitmapData(uint256 tokenId) public pure returns (bytes memory) {
        Bitmap memory bitmap;
        bitmap.init(XY(32, 32));
        bytes32 data = keccak256(abi.encodePacked("BitmapNFT", tokenId));
        uint256 bmpPattern = uint256(data) % 6;
        if (bmpPattern == 0) {
            vertical(bitmap, data);
        } else if (bmpPattern == 1) {
            horizontal(bitmap, data);
        } else if (bmpPattern == 2) {
            square(bitmap, data);
        } else if (bmpPattern == 3) {
            cross(bitmap, data);
        } else if (bmpPattern == 4) {
            diagonal(bitmap, data);
        } else {
            diagonal2(bitmap, data);
        }
        return bitmap.data;
    }

    function getBitmapBase64(uint256 tokenId)
        public
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:image/bmp;base64,",
                    Base64.encode(getBitmapData(tokenId))
                )
            );
    }

    function getSVG(uint256 tokenId) public pure returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
                '<image x="0" y="0" height="32px" width="32px" style="image-rendering: pixelated; width:100%; height: 100%" preserveAspectRatio="xMinYMin meet" href="',
                getBitmapBase64(tokenId),
                '"/></svg>'
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(svg))
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        string memory metadata = string(
            abi.encodePacked(
                '{"name": "BitmapNFT #',
                toString(tokenId),
                '",',
                '"description": "BitmapNFT",',
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(getSVG(tokenId))),
                '"}'
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(metadata))
                )
            );
    }

    function vertical(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 32);
        for (int256 i = 0; i < 32; i++) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32; j++) {
                bitmap.setPixel(XY(i, j), pixel);
            }
        }
    }

    function horizontal(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 32);
        for (int256 i = 0; i < 32; i++) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32; j++) {
                bitmap.setPixel(XY(j, i), pixel);
            }
        }
    }

    function cross(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 16);
        for (int256 i = 0; i < 16; i++) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32; j++) {
                bitmap.setPixel(XY(i, j), pixel);
                bitmap.setPixel(XY(31 - i, j), pixel);
                bitmap.setPixel(XY(j, i), pixel);
                bitmap.setPixel(XY(j, 31 - i), pixel);
            }
        }
    }

    function square(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 16);
        for (int256 i = 15; i >= 0; i--) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32; j++) {
                bitmap.setPixel(XY(i, j), pixel);
                bitmap.setPixel(XY(31 - i, j), pixel);
                bitmap.setPixel(XY(j, i), pixel);
                bitmap.setPixel(XY(j, 31 - i), pixel);
            }
        }
    }

    function diagonal(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 16);
        for (int256 i = 15; i >= 0; i--) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32 - i; j++) {
                bitmap.setPixel(XY(i, 0).add(j, j), pixel);
                bitmap.setPixel(XY(0, i).add(j, j), pixel);
                bitmap.setPixel(XY(i, 31).add(j, -j), pixel);
                bitmap.setPixel(XY(0, 31 - i).add(j, -j), pixel);
            }
        }
    }

    function diagonal2(Bitmap memory bitmap, bytes32 data) internal pure {
        PixelFactory memory factory;
        factory.init(data, 16);
        for (int256 i = 0; i < 16; i++) {
            RGB memory pixel = factory.create(i);
            for (int256 j = 0; j < 32 - i; j++) {
                bitmap.setPixel(XY(i, 0).add(j, j), pixel);
                bitmap.setPixel(XY(0, i).add(j, j), pixel);
                bitmap.setPixel(XY(i, 31).add(j, -j), pixel);
                bitmap.setPixel(XY(0, 31 - i).add(j, -j), pixel);
            }
        }
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
