# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Minlopro DX is a Salesforce DX project built on a Free Developer Org. It uses a multi-package architecture with 9 separate packages, Salesforce API version 64.0, Node.js >=20.x, and npm >=10.x.

## Common Commands

```bash
# Formatting
npm run prettier:write                  # Format all files (uses custom shell script)
npm run prettier:src:check              # Check formatting without changes

# LWC Jest Tests
npm run jest                            # Run all LWC Jest tests
npm run jest -- --testPathPattern=<pattern>  # Run specific LWC test

# Salesforce Tests
npm run sf:apex:tests                   # Run all Apex tests with coverage
npm run sf:flow:tests                   # Run all Flow tests

# Deployment
npm run src:push                        # Push source to default org (uses .env for replacements)
npm run src:pull                        # Retrieve from org
npm run src:deploy                      # Full deploy to target org
npm run src:deploy:check                # Dry-run deploy (validation only)

# Manifests
npm run sf:manifest:create:full         # Generate full package.xml
npm run sf:manifest:create:delta        # Generate delta manifest (changed files only)

# Code Quality
npm run sf:code-analyzer:run            # Run Salesforce Code Analyzer

# Dev Server
npm run sf:lightning:dev:app             # Launch Lightning dev app (MinloproConsole)
```

## Package Architecture

Source is in `src/` with 9 packages deployed in this order (defined in `sfdx-project.json`):

1. **minlopro-default** - Default/base metadata
2. **minlopro-core** - Core infrastructure: fflib (enterprise patterns), Logger, TriggerDispatcher, FeatureToggle, utility classes
3. **minlopro** - Main application: POC implementations, LWC components, Apex services, triggers
4. **minlopro-integrations** - Auth providers, external credentials, named credentials, API integrations
5. **minlopro-digex** - Digital Experience (Community) site
6. **minlopro-digex-messaging** - In-app messaging for Digital Experience
7. **minlopro-dlrs** - Declarative Lookup Rollup Summaries
8. **minlopro-in-app-guidance** - In-app guidance features
9. **minlopro-crm-analytics** - CRM Analytics dashboards/datasets

## Core Patterns (minlopro-core)

### Trigger Framework
One trigger per object, delegating to `TriggerDispatcher`:
```apex
trigger AccountTrigger on Account(...) {
    TriggerDispatcher.setContext(Account.SObjectType).run();
}
```
- `TriggerDispatcher` reads `TriggerHandler__mdt` custom metadata to load active handlers in order
- Handlers extend `BasicTriggerHandler` and override phase methods (beforeInsert, afterUpdate, etc.)
- Supports bypass and loop count validation

### fflib Enterprise Patterns
`Application.cls` is the central IoC container with four factories:
- **ServiceFactory** - Business logic services
- **SelectorFactory** - SOQL query classes (e.g., `AccountSelector`)
- **DomainFactory** - Domain logic classes
- **UnitOfWorkFactory** - Batched DML operations

### Feature Toggles
`FeatureToggle.cls` reads `FeatureToggle__mdt` custom metadata for runtime feature flags without redeployment.

### Logger
Custom logging framework: `Logger.cls` for writing logs, `LoggerCleanupBatch` for cleanup, `LogsMonitorPanelController` for an LWC monitoring panel.

## Environment Variables

The `.env` file provides values that `sfdx-project.json` replacements substitute at deploy time (e.g., `${SF_ADMIN_EMAIL}`, `${SF_INSTANCE_URL}`, `${SF_SITE_DOMAIN_NAME}`). The `src:push` command uses `dotenv-cli` to load these automatically.

## CI/CD (GitHub Actions)

- **validate-pull-request.yml** - PR validation: Prettier check, Jest tests, ShellCheck, dry-run deploy, code analyzer
- **run-deployment.yml** - Scheduled/manual deployment: full deploy, Apex tests, code analyzer, post-merge actions
- **create-scratch-org.yml** - Scratch org spin-up with full source deploy and test execution
- **run-code-analyzer.yml** - Reusable code analysis workflow

PR target branch: `develop`. Deploy scripts are in `scripts/deploy/`.

## Git Workflow

- `develop` is the main integration branch
- Feature branches (e.g., `feature/poc`) target `develop` via PR
- PR validation gates: formatting, Jest tests, shell linting, dry-run deploy

## Code Conventions (from CODECONVENTIONS.md)

### Apex
- PascalCase classes, camelCase methods/variables, UPPERCASE constants
- Boolean prefixes: `is`, `has`, `should`, `can`
- One trigger per object, delegate to handler classes
- Bulkify code; no SOQL/DML in loops
- Separation of concerns: Controller -> Service -> Selector
- Wrap `@AuraEnabled` methods in try-catch, throw `AuraHandledException`
- Use `RecordType.DeveloperName` (not `Name`) for locale independence
- Tests: minimum 85% coverage, use `Test.startTest()`/`Test.stopTest()`, no `@SeeAllData=true`

### LWC
- camelCase JS, kebab-case components
- Event handlers: `handle{EventName}` pattern
- Use `@wire` for data, `@api` for public properties
- Prefer `lightning-*` base components and SLDS classes
- Clean up in `disconnectedCallback`
- Use `CustomEvent` for events; bubble only when necessary

### Aura
- camelCase attributes, PascalCase component names
- Minimal controller logic; delegate to helpers
- Application events suffixed with `Evt`

## Testing

- **LWC**: Jest with `@salesforce/sfdx-lwc-jest`. Config in `jest.config.js`. Mock stubs in `src/minlopro-core/test/jest-mocks/`.
- **Apex**: `@isTest` classes, ApexMocks for mocking, programmatic test data (no org data dependency).
- **Flows**: `sf flow run test` command.

## Formatting

Prettier with plugins for Apex, XML, and SQL. Config in `.prettierrc.json`:
- Tab width: 4, single quotes, trailing commas: none, print width: 130
- File-specific overrides for different source types

## Generated Flow Documentation

Flow documentation is auto-generated as Markdown into `assets/docs/hardis/flow2markdown/flows/` using the `sf hardis:doc:flow2markdown` plugin. Each `.flow-meta.xml` in `src/` produces a corresponding `.md` file describing the flow's structure.

- **Generate locally**: `bash ./scripts/util/flows-mgmt/generate_flow_docs.sh`
- **CI auto-generation**: After merges to `develop`, the `generate_flow_docs_and_push.sh` post-merge action regenerates docs and commits them if changed.

## MCP Integration

Salesforce MCP server configured in `.mcp.json` for Claude interactions with the default target org.
