# Audit Salesforce Metadata API Versions

## Command Purpose
Analyze all Salesforce metadata components in the project to identify API version distribution and technical debt. Generate a pivot table showing component counts grouped by metadata type and API version.

## Execution Instructions

### Step 1: Validate Environment
1. Verify the `src/` directory exists in the current working directory
2. If `src/` doesn't exist, inform the user and ask for the correct metadata directory path
3. Check if `build/` directory exists; create it if missing

### Step 2: Leverage the Audit Script

Use existing "scripts/util/metadata/audit-api-versions.sh" bash script that does the following:

**Script Requirements:**
- Recursively scan all files in `src/` directory
- Target these file patterns:
    - `*.cls` (Apex Classes)
    - `*.trigger` (Apex Triggers)
    - `*.page` (Visualforce Pages)
    - `*.component` (Visualforce Components)
    - `*.flow` (Flows)
    - `*-meta.xml` (Metadata XML files)
- Extract `<apiVersion>` tag values from XML content
- For `.cls`, `.trigger`, `.page`, `.component` files, check their companion `-meta.xml` files
- For `.flow` files and LWC/Aura components, extract version from the file itself

**Data Aggregation:**
- Create a matrix structure: `MetadataType × APIVersion = Count`
- Track totals for each metadata type
- Track totals for each API version
- Handle cases where API version is not found (skip those files)

**Output Format:**
- File location: `build/metadata-api-version-audit.csv`
- CSV structure:
```
  # Metadata Audit Report Header (commented lines)
  Metadata Type,API 40.0,API 45.0,API 50.0,...,Total
  ApexClass,5,10,25,...,40
  ApexTrigger,2,3,8,...,13
  ...
  TOTAL,7,13,33,...,53
```

### Step 3: Execute the Script
1. Make the script executable: `chmod +x audit-api-versions.sh`
2. Run the script: `./audit-api-versions.sh`
3. Capture both stdout and any errors

### Step 4: Analyze Results
1. Read and parse `build/metadata-api-version-audit.csv`
2. Display the pivot table in a formatted terminal-friendly table
3. Calculate and present these insights:

**Critical Metrics:**
- Total components analyzed
- Number of unique metadata types
- API version range (oldest → newest)
- Current Salesforce release version context
- Components on deprecated API versions (< Current - 3 releases)
- Components approaching deprecation (Current - 2 releases)

**Risk Assessment:**
- Categorize components by risk level:
    - 🔴 **Critical**: API versions older than 3 releases (at risk of removal)
    - 🟡 **Warning**: API versions 2-3 releases old (approaching deprecation)
    - 🟢 **Healthy**: API versions within last 2 releases

### Step 5: Provide Recommendations
Based on the audit results, provide:

1. **Immediate Actions** (if critical risk components found)
    - List specific metadata types requiring urgent updates
    - Estimated effort (e.g., "12 Apex classes need version updates")

2. **Maintenance Strategy**
    - Suggest quarterly audit cadence
    - Recommend API version standardization (e.g., "Move all to v62.0")

3. **Automation Opportunities**
    - Propose CI/CD integration (GitHub Actions example)
    - Suggest pre-commit hooks to prevent old API versions

4. **Technical Debt Score**
    - Calculate: `(Components on old versions / Total components) × 100`
    - Provide benchmark context (e.g., "<10% is excellent, >30% needs attention")

### Step 6: Cleanup and Documentation
1. Confirm the CSV file was created successfully
2. Offer to add the audit script to `.gitignore` or commit it to the repo
3. Suggest adding this command to project documentation

## Expected Output Format

Display results in this structure:
```
╔════════════════════════════════════════════════════════════════════╗
║         SALESFORCE METADATA API VERSION AUDIT REPORT              ║
╚════════════════════════════════════════════════════════════════════╝

📊 Audit Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Total Components:        189
  Metadata Types:          5
  API Versions Found:      42.0 → 62.0
  Deprecated Components:   23 (12.2%)

[Display formatted pivot table here]

⚠️  Risk Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔴 Critical (< v50.0):   23 components
  🟡 Warning (v50.0-55.0): 38 components
  🟢 Healthy (> v55.0):    128 components

💡 Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [Specific, actionable recommendations here]

📁 Report saved to: build/metadata-api-version-audit.csv
```

## Error Handling
- If `src/` directory is missing: Prompt user for correct path
- If no metadata files found: Display warning and exit gracefully
- If CSV generation fails: Show error and provide manual troubleshooting steps
- If API version extraction fails for all files: Verify XML structure and provide example

## Additional Context
- Salesforce retires API versions 3 releases after deprecation (~18 months)
- Current Salesforce release cycle: 3 major releases per year
- Best practice: Keep metadata within last 5 API versions
- This audit does NOT make any changes to metadata files (read-only operation)

## Success Criteria
✅ Script executes without errors
✅ CSV file generated in `build/` directory
✅ Pivot table displays complete data
✅ Risk assessment identifies actionable items
✅ Recommendations are specific to the analyzed codebase