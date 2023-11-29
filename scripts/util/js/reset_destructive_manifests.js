const fs = require("fs");
const xml2js = require("xml2js");

/**
 * How to use:
 * - node scripts/util/js/reset_destructive_manifests.js
 */

const $Parser = new xml2js.Parser();
const $Builder = new xml2js.Builder();

// Function to remove '<types>' tags;
function resetManifestXmlContent(xmlObject) {
  if (xmlObject && typeof xmlObject === "object") {
    Object.keys(xmlObject).forEach(key => {
      if (key === "types") {
        delete xmlObject[key]; // Delete the 'types' key
      } else if (typeof xmlObject[key] === "object") {
        resetManifestXmlContent(xmlObject[key]); // Recurse into other objects
      }
    });
  }
}

// Invoke file cleanup for each destructive manifest file
[
  "manifests/destructiveChangesPre.xml",
  "manifests/destructiveChangesPost.xml"
].forEach(manifestFilePath => {
  // Read the XML file
  fs.readFile(manifestFilePath, (err, data) => {
    if (err) {
      throw new Error(`Error reading XML file: ${err}`);
    }
    // Parse XML to JavaScript object
    $Parser.parseString(data, (err, xmlAsObject) => {
      if (err) {
        throw new Error(`Error parsing XML file: ${err}`);
      }
      resetManifestXmlContent(xmlAsObject);
      // Convert JavaScript object back to XML
      const xml = $Builder.buildObject(xmlAsObject);
      // Write the modified XML
      fs.writeFile(manifestFilePath, xml, (err) => {
        if (err) {
          throw new Error(`Error writing the modified XML file: ${err}`);
        }
        console.log(`Successfully written to ${manifestFilePath}`);
      });
    });
  });
});
