# minlopro-dx

[![DEVELOP Branch Workflow](https://github.com/awesomeandrey/minlopro-dx-playground/actions/workflows/develop_workflow.yml/badge.svg?branch=develop&event=push)](https://github.com/awesomeandrey/minlopro-dx-playground/actions/workflows/develop_workflow.yml)

## Prerequisites

Install `node` version according to `package.json` file (_19.7.0_). It's recommended to
use [NVM](https://tecadmin.net/install-nvm-macos-with-homebrew/) in order to manage NODE versions on
local machine.

Run `npm install` in order to load project dependencies.

Look through the pre-configured GitHub Workflows/Actions located in `.github/workflows/` folder.

Make sure that the changed codebase files are _prettified_ via `npm run prettier` command.
Alternatively, you can run `npm run prettier:check` in order to identify _non-prettified_ files.

### Branches

_`main`_

Comprises all source code in the repository.

_`develop`_

Used for features development. Descendant of `main` branch. This branch should always be synced up with `main` branch
once the feature(s) has been developed, tested and pushed to release.

Corresponds to **QA** environment.

_`release/**`_

Holds a bundle of features for specific release. Descendant of `develop` branch. Should always be synced up with `main`
branch once the release features have been deployed & tested on production org.

Corresponds to **PROD** environment.

### Useful Commands

_Create DigEx Site_

```
sfdx force:community:create \
    --u SO \
    --name 'DigEx' \
    --templatename 'Build Your Own' \
    --urlpathprefix digex
```

_Create Scratch Org_

```
// Create scratch org according to JSON config file;
sfdx force:org:create -f config/project-scratch-def.json -a SO

[Push Source Code to the newly created Scratch Org]

// Create extra user (optional)
sfdx force:user:create \
    -u SO \
    --definitionfile config/qa-user-def.json \
    --setalias qa-user \
    --set-unique-username

// Assign permission set groups to target users

# bash ./scripts/run_apex_script.sh SO_alias assign_minlopro_digex_psg
# bash ./scripts/run_apex_script.sh SO_alias assign_minlopro_psg
# bash ./scripts/run_apex_script.sh SO enable_debug_mode
```

_Publish Community_

```
sfdx force:community:publish --name "DigEx" -u SO
```

_Generate Auth URL for the Target Org_

```
// Authorize Org (defining 'targetOrg' alias)
sfdx auth:web:login --setalias targetOrg
// Generate auth URL and save it to the file './org_auth_url.txt'
sfdx auth:sfdxurl:store -f ./org_auth_url.txt -a targetOrg -d -s
// Print org info
sfdx force:org:display --verbose -a targetOrg
```

_Deploy Repository Source to Target Org_

```
// Create 'package.xml' manifest file that lists all metadata components within the repo
sfdx force:source:manifest:create --sourcepath minlopro --manifestname manifests/package.xml
// Initiate source code deployment
sfdx force:source:deploy \
    -x manifests/package.xml \
    --predestructivechanges manifests/destructiveChangesPre.xml \
    --postdestructivechanges manifests/destructiveChangesPost.xml \
    --checkonly \
    --verbose \
    --testlevel=RunLocalTests \
    --ignorewarnings
```

The following flags are optional:

-   `--checkonly` - used to validate bundle deployment
-   `--testlevel` - used to invoke Apex Tests during deployment

_Invoke All Apex Tests_

```
sfdx force:apex:test:run --code-coverage --result-format human -d ./coverage
```

_Reset Source Tracking Locally_

```
sfdx force:source:tracking:clear -u SO -p
```

_Retrieve Metadata From Org by `package.xml` File_

```
sfdx force:source:retrieve -x manifests/package.xml -u SO -r build
```

_Generate `package.xml` File Based on Changes Delta_

This implies [sfdx-git-delta](https://github.com/scolladon/sfdx-git-delta) plugin usage.

```
// Install plugin once
sfdx plugins:install sfdx-git-delta@stable
// Generate manifest files that indicate source changes
sfdx sgd:source:delta \
    --output manifests \
    --source 'src' \
    --from "SOURCE_BRANCH_NAME" \
    --to "WORKING_BRANCH_NAME"
```


_Generate User Password_
```
sfdx force:user:password:generate -u SO
sfdx user:display -u SO
```

### Scripts in `package.json`

Aforementioned commands were broken down into smaller ones in `package.json` project file.
Keep im mind that scripts that start with `sfdx:...` or `src:...` can be invoked with extra parameters passed to them.
E.g. you can execute particular script passing in ORG alias:

```
// Authorize Org
npm run sfdx:auth:create -- -u [AUTHORIZED_ORG_ALIAS] && npm run sfdx:auth:store
// Validate deployment to target ORG
npm run sfdx:manifest && npm run src:deploy:check -- -u [AUTHORIZED_ORG_ALIAS]
// Run deployment to target ORG that has source tracking enabled (such as sandboxes and scratch orgs)
npm run sfdx:manifest && npm run src:deploy:full -- -u [AUTHORIZED_ORG_ALIAS] --tracksource --forceoverwrite
```

Please, refer
to [SFDX CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
for more information.
