import fs from 'fs';
import CryptoJS from 'crypto-js';

/**
 * How to use:
 * - node scripts/util/js/encode_decode_server_key.js
 */

function decodeBase64ToString(base64encodedValue) {
    const wordArray = CryptoJS.enc.Base64.parse(base64encodedValue);
    const decodedValue = CryptoJS.enc.Utf8.stringify(wordArray);
    return Promise.resolve(decodedValue);
}

function encodeFileToBase64(filePath) {
    return fs.promises.readFile(filePath).then((data) => {
        // Convert the binary data to a WordArray;
        const wordArray = CryptoJS.lib.WordArray.create(data);
        // Convert the WordArray to a Base64 string;
        return CryptoJS.enc.Base64.stringify(wordArray);
    });
}

const filePath = '/path/server.key';
encodeFileToBase64(filePath)
    .then((base64Encoded) => {
        console.log('Base64 Encoded String:', base64Encoded);
        return base64Encoded;
    })
    .then((base64Encoded) => decodeBase64ToString(base64Encoded))
    .then((decodedValue) => {
        console.log('Base64 Decoded Text:', decodedValue);
    })
    .catch((err) => {
        console.error('Error!!!', err);
    });
