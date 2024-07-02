import readline from 'readline';
import fs from 'fs';

/**
 * How to use:
 * - node ./scripts/crm-analytics/js/compose_app_manifest_from_metadata.js
 * - echo "FOLDER_PATH_WITH_WAVE_METADATA" | node ./scripts/crm-analytics/js/compose_app_manifest_from_metadata.js
 */

// Create an interface for reading inputs
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

// Function to ask for input
const askForInput = (question) => {
    return new Promise((resolve) => rl.question(question, resolve));
};

// Static map of salesforce metadata types
const METADATA_TYPES = {
    wapp: { name: 'WaveApplication' },
    wdash: { name: 'WaveDashboard' },
    wds: { name: 'WaveDataset' },
    wlens: { name: 'WaveLens' },
    wdpr: { name: 'WaveRecipe' },
    wdf: { name: 'WaveDataflow' }
};

// Main function to run the script
const main = async () => {
    try {
        const folderPath = await askForInput('Enter folder pathname with WAVE metadata files: ');
        console.log(`Analyzing WAVE file names in ${folderPath} folder...`);

        // Read filenames, determine its metadata type & group API names;
        const filenames = fs.readdirSync(folderPath) || [];
        let apiNamesByType = filenames.reduce((acc, filename = '') => {
            let [metadataApiName, metadataType] = filename.substring(0, filename.indexOf('-meta.xml')).split('.');
            console.log(`${filename} -> ApiName=${metadataApiName}; Type=${metadataType}`);
            acc[metadataType] = acc[metadataType] || [];
            acc[metadataType].push(metadataApiName);
            return acc;
        }, {});
        const metadataTypesAsArray = Object.keys(apiNamesByType).map((type) => {
            return {
                name: METADATA_TYPES[type].name,
                members: Array.from(new Set(apiNamesByType[type]))
            };
        });

        // Add XMD files for datasets manually;
        let datasetsMetadata = metadataTypesAsArray.find(({ name }) => name === 'WaveDataset');
        if (datasetsMetadata?.members?.length) {
            metadataTypesAsArray.push({
                name: 'WaveXmd',
                members: datasetsMetadata.members
            });
        }

        // Generate manifest XML snippets;
        console.log('\n----- Manifest Snippets -----\n');
        let str = '';
        str += '<?xml version="1.0" encoding="UTF-8"?>';
        str += '\n<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n';
        str += metadataTypesAsArray
            .map(({ name, members = [] }) => {
                let str = '';
                str += '<types>\n';
                members.forEach((apiName) => (str += `\t<members>${apiName}</members>\n`));
                str += `\t<name>${name}</name>`;
                str += '\n</types>';
                return str;
            })
            .join('\n');
        str += '\n<version>60.0</version>';
        str += '\n</Package>';

        // Write to file
        fs.writeFileSync('temp/crma-package.xml', str);
    } catch (error) {
        console.error('An error occurred:', error);
    } finally {
        // Close the readline interface
        rl.close();
    }
};

// Run the main function
main();
