import jwt from 'jsonwebtoken';
import fs from 'fs';

/**
 * How to use:
 * - node scripts/util/js/generate_jwt.js
 *
 * ### How to generate certificate-key pair?
 *
 * Run this command in bash:
 * openssl req -newkey rsa:2048 -nodes -keyout server.key -x509 -days 3650 -out server.crt
 * Outputs:
 * - server.key = RSA private key
 * - server.crt = Self-signed certificate (this one should be uploaded to connected app def)
 *
 * ### How to generate JWT based on private key?
 *
 * Use scripts/util/js/generate_jwt.js Node script to generate the JWT!
 *
 * ### What should be the HTTP request payload to request access token?
 *
 * Use scripts/util/js/request_access_token_by_jwt.js Node script to request access token!
 */

// Replace these variables with your actual values;
export const $credentials = {
    clientId: 'connected_app_client_id',
    userName: 'integration_user_username',
    privateKeyPath: '/path/server.key',
    audience: 'https://test.salesforce.com'
};

export const generateJwt = () => {
    // Read your private key
    const privateKey = fs.readFileSync($credentials.privateKeyPath, 'utf8');
    // Define the JWT payload
    const payload = {
        iss: $credentials.clientId,
        sub: $credentials.userName,
        aud: $credentials.audience,
        exp: Math.floor(Date.now() / 1000) + 60 * 3 // Token expiration time (3 minutes from now)
    };
    // Sign the JWT with your private key
    const token = jwt.sign(payload, privateKey, { algorithm: 'RS256' });
    console.log('JWT Token:', token);
    return token;
};

generateJwt();
