/**
 * How to use:
 * - node scripts/util/js/apigee_x_log_builder.js
 */

const $RuntimeLogDetails = {
  "message_id": "{messageid}", // +
  "message.status.code": "{message.status.code}", // +
  "message.reason.phrase": "{message.reason.phrase}", // +
  "client_ip": "{client.ip}", // +
  "request.verb": "{request.verb}", // +
  "request.url": "{request.url}", // +
  "request.querystring": "{request.querystring}", // +
  "request.header.contentLength": "{request.header.Content-Length}",
  "request.header.contentType": "{request.header.Content-Type}",
  // "request.content": "{request.content}",
  "response.status.code": "{response.status.code}", // +
  "response.header.contentLength": "{response.header.Content-Length}",
  "response.header.contentType": "{response.header.Content-Type}",
  // "response.content": "{response.content}",
  "apiproduct.name": "{apiproduct.name}", // +
  "apiproxy.revision": "{apiproxy.revision}", // +
  "proxy.basepath": "{proxy.basepath}", // +
  "proxy.pathsuffix": "{proxy.pathsuffix}", // +
  // "proxy.url": "{proxy.url}",
  "target.url": "{target.url}",
  "target.response.status.code": "{target.response.status.code}", // +
  "response.content": "{stringifiedResponseContent}" // + custom variable generated at runtime
};

const $RuntimeErrorDetails = {
  "error.status.code": "{error.status.code}",
  "error.reason.phrase": "{error.reason.phrase}",
  "error.message": "{error.message}",
  "fault.name": "{fault.name}"
};

function toLogMessage(obj) {
  return Object.keys(obj).sort().map(key => {
    let value = obj[key];
    return `${key.replaceAll(".", "_")}=${value}`;
  }).join(", ");
}

console.log("INFO Message", `INFO: {system.time} ${toLogMessage($RuntimeLogDetails)}`);
console.log("ERROR Message", `ERROR: {system.time} ${toLogMessage($RuntimeErrorDetails)}, ${toLogMessage($RuntimeLogDetails)}`);
