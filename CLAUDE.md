# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Minlopro DX is an educational Salesforce DX project — a playground/sandbox for learning Salesforce clouds (Sales, Service, Experience Sites, CRM Analytics), building and testing proof-of-concepts (POCs), and trying out managed/unmanaged package solutions. Built on a Free Developer Org.

## Project Structure

Metadata lives under `src/`, organized into semantic package directories declared in `sfdx-project.json` (deployed in the order listed there). Each package directory under `src/` should have its own `README.md` with a high-level overview of the metadata it contains — read it before working in that package, and add one if it's missing.

## Code Conventions

Conventions for Apex, LWC, and Aura are defined in `CODECONVENTIONS.md` — always follow them.

- Always prefer standard/base Lightning components (`lightning-*`) over custom-built ones; reach for a custom implementation only when the task's complexity genuinely requires it.

## UI / Visual Design

- Follow SLDS (Salesforce Lightning Design System) v1 for all UI work.
- For component look and feel, reference the [SLDS2 Starter Kit](https://salesforce-ux.github.io/design-system-2-starter-kit/#/app) — it shows styled UI representations of common SLDS elements.

## Common Commands

Scripts are defined in `package.json`. Key ones:

- Deploying metadata to a scratch/target org: use the `/push-metadata-to-scratch-org` skill (don't call `sf project deploy` manually).
- Other npm scripts (formatting, tests, manifests, code analysis) — see `package.json` directly for the full, current list.

The `scripts/` directory (`scripts/util/`, `scripts/deploy/`, `scripts/automations/`) contains the bash/CI scripts backing these commands — treat it as the knowledge base for how a given command actually works.

## Workflow

When a new feature request arrives, always suggest switching to plan mode and ask clarifying questions before implementing.

## Other Notes

- Git: `develop` is the main integration branch; feature branches target it via PR. PR validation gates formatting, Jest tests, shell linting, and a dry-run deploy.
- Environment variables: `.env` supplies values substituted into metadata at deploy time via the `replacements` block in `sfdx-project.json` (e.g. `${SF_ADMIN_EMAIL}`, `${SF_INSTANCE_URL}`, `${SF_SITE_DOMAIN_NAME}`). `src:push` loads `.env` automatically via `dotenv-cli`.
