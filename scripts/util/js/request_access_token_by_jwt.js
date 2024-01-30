import { generateJwt, $credentials } from './generate_jwt.js';
import https from 'https';

/**
 * How to use:
 * - node scripts/util/js/request_access_token_by_jwt.js
 */

// Generate JWT;
const token = generateJwt();

// Salesforce token request endpoint;
const audience = $credentials.audience;
const tokenUrl = new URL(`${audience}/services/oauth2/token`);

// Prepare the request body;
const tokenRequestBody = new URLSearchParams({
    grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    assertion: token
}).toString();
const requestOptions = {
    hostname: tokenUrl.hostname,
    path: tokenUrl.pathname + tokenUrl.search,
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
};

// Make the request for the access token;
const req = https.request(requestOptions, (res) => {
    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });
    res.on('end', () => {
        console.log('Access Token Response:', JSON.parse(data));
    });
});
req.on('error', (e) => {
    console.error('Error requesting access token:', e);
});
req.write(tokenRequestBody);
req.end();
