# Push Metadata to Scratch Org

Deploy local source changes to the connected Salesforce scratch org by formatting code and pushing metadata.

## Steps

1. **Format** — Run `npm run prettier:write` to apply Prettier formatting to all changed files.
2. **Push** — Run `npm run src:push` to deploy the source to the default scratch org.

Run these sequentially; do not push if formatting fails.