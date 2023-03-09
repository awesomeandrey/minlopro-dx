# minlopro-dx

TODO - Describe the project

### Branches

*`main`*

Comprises all source code in the repository.

*`develop`*

Used for features development. Descendant of `main` branch. This branch should always be synced up with `main` branch once the feature(s) has been developed, tested and pushed to release.

Corresponds to **QA** environment.

*`release/**`*

Holds a bundle of features for specific release. Descendant of `develop` branch. Should always be synced up with `main` branch once the release features have been deployed & tested on production org.

Corresponds to **PROD** environment.

### Useful Commands

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
- `--checkonly` - used to validate bundle deployment
- `--testlevel` - used to invoke Apex Tests during deployment

_Invoke All Apex Tests_

```
sfdx force:apex:test:run --code-coverage --result-format human -d ./coverage
```
