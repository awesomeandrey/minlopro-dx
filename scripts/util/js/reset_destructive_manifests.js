import fs from "fs";
import path from "path";
import xml2js from "xml2js";

/**
 * How to use:
 * - node scripts/util/js/reset_destructive_manifests.js
 */

const $Parser = new xml2js.Parser();
const $Builder = new xml2js.Builder();

// Function to remove '<types>' tags
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
(async filesArray => {
  for (const manifestFilePath of filesArray) {
    try {
      // Resolve absolute file path
      const absoluteFilePath = path.resolve(manifestFilePath);
      // Read raw file content
      const fileContentAsString = await fs.promises.readFile(absoluteFilePath, "utf-8");
      // Convert file content to XML object
      const fileContentAsXmlObject = await $Parser.parseStringPromise(fileContentAsString);
      // Normalize XML tree
      resetManifestXmlContent(fileContentAsXmlObject);
      // Convert JavaScript object back to XML representation
      const resultXml = $Builder.buildObject(fileContentAsXmlObject);
      // Write back to XML file
      await fs.promises.writeFile(absoluteFilePath, resultXml);
      console.log(`Successfully written to [${manifestFilePath}].`);
    } catch (error) {
      console.error(`Error resetting [${manifestFilePath}] manifest`, error);
      process.exit(1);
    }
  }
})(["manifests/destructiveChangesPre.xml", "manifests/destructiveChangesPost.xml"]);
