#!/usr/bin/env bash

# Salesforce Metadata API Version Audit Script
# Scans src/ for metadata components and extracts API versions
# Outputs a pivot table CSV to build/metadata-api-version-audit.csv

set -euo pipefail

SRC_DIR="src"
OUTPUT_FILE="build/metadata-api-version-audit.csv"

if [[ ! -d "$SRC_DIR" ]]; then
    echo "ERROR: '$SRC_DIR' directory not found." >&2
    exit 1
fi

# Temporary working files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

RAW_DATA="$TMP_DIR/raw_data.tsv"
: > "$RAW_DATA"

extract_api_version() {
    local file="$1"
    sed -n 's/.*<apiVersion>\([^<]*\)<\/apiVersion>.*/\1/p' "$file" 2>/dev/null | head -1
}

classify_metadata_type() {
    local file="$1"
    case "$file" in
        *.cls-meta.xml)       echo "ApexClass" ;;
        *.trigger-meta.xml)   echo "ApexTrigger" ;;
        *.page-meta.xml)      echo "VisualforcePage" ;;
        *.component-meta.xml) echo "VisualforceComponent" ;;
        *.flow-meta.xml)      echo "Flow" ;;
        *)
            # Classify by directory structure for other -meta.xml files
            if [[ "$file" == *"/lwc/"* ]]; then
                echo "LightningWebComponent"
            elif [[ "$file" == *"/aura/"* ]]; then
                echo "AuraComponent"
            elif [[ "$file" == *"/permissionsets/"* ]]; then
                echo "PermissionSet"
            elif [[ "$file" == *"/profiles/"* ]]; then
                echo "Profile"
            elif [[ "$file" == *"/objects/"* ]]; then
                echo "CustomObject"
            elif [[ "$file" == *"/layouts/"* ]]; then
                echo "Layout"
            elif [[ "$file" == *"/tabs/"* ]]; then
                echo "CustomTab"
            elif [[ "$file" == *"/applications/"* ]]; then
                echo "CustomApplication"
            elif [[ "$file" == *"/staticresources/"* ]]; then
                echo "StaticResource"
            elif [[ "$file" == *"/contentassets/"* ]]; then
                echo "ContentAsset"
            elif [[ "$file" == *"/flexipages/"* ]]; then
                echo "FlexiPage"
            elif [[ "$file" == *"/customMetadata/"* ]]; then
                echo "CustomMetadata"
            elif [[ "$file" == *"/email/"* ]]; then
                echo "EmailTemplate"
            elif [[ "$file" == *"/reportTypes/"* ]]; then
                echo "ReportType"
            elif [[ "$file" == *"/reports/"* ]]; then
                echo "Report"
            elif [[ "$file" == *"/dashboards/"* ]]; then
                echo "Dashboard"
            elif [[ "$file" == *"/approvalProcesses/"* ]]; then
                echo "ApprovalProcess"
            elif [[ "$file" == *"/assignmentRules/"* ]]; then
                echo "AssignmentRules"
            elif [[ "$file" == *"/autoResponseRules/"* ]]; then
                echo "AutoResponseRules"
            elif [[ "$file" == *"/escalationRules/"* ]]; then
                echo "EscalationRules"
            elif [[ "$file" == *"/matchingRules/"* ]]; then
                echo "MatchingRules"
            elif [[ "$file" == *"/sharingRules/"* ]]; then
                echo "SharingRules"
            elif [[ "$file" == *"/workflows/"* ]]; then
                echo "Workflow"
            elif [[ "$file" == *"/globalValueSets/"* ]]; then
                echo "GlobalValueSet"
            elif [[ "$file" == *"/standardValueSets/"* ]]; then
                echo "StandardValueSet"
            elif [[ "$file" == *"/queues/"* ]]; then
                echo "Queue"
            elif [[ "$file" == *"/groups/"* ]]; then
                echo "Group"
            elif [[ "$file" == *"/roles/"* ]]; then
                echo "Role"
            elif [[ "$file" == *"/sites/"* ]]; then
                echo "CustomSite"
            elif [[ "$file" == *"/networks/"* ]]; then
                echo "Network"
            elif [[ "$file" == *"/experiences/"* || "$file" == *"/digitalExperiences/"* ]]; then
                echo "DigitalExperience"
            elif [[ "$file" == *"/namedCredentials/"* ]]; then
                echo "NamedCredential"
            elif [[ "$file" == *"/externalCredentials/"* ]]; then
                echo "ExternalCredential"
            elif [[ "$file" == *"/authproviders/"* ]]; then
                echo "AuthProvider"
            elif [[ "$file" == *"/connectedApps/"* ]]; then
                echo "ConnectedApp"
            elif [[ "$file" == *"/labels/"* ]]; then
                echo "CustomLabel"
            elif [[ "$file" == *"/messageChannels/"* ]]; then
                echo "LightningMessageChannel"
            elif [[ "$file" == *"/platformEventChannelMembers/"* ]]; then
                echo "PlatformEventChannelMember"
            elif [[ "$file" == *"/settings/"* ]]; then
                echo "Settings"
            else
                echo "Other"
            fi
            ;;
    esac
}

echo "Scanning metadata files in '$SRC_DIR'..."

# For .cls, .trigger, .page, .component files — check companion -meta.xml
while IFS= read -r -d '' file; do
    meta_file="${file}-meta.xml"
    if [[ -f "$meta_file" ]]; then
        version=$(extract_api_version "$meta_file")
        if [[ -n "$version" ]]; then
            mtype=$(classify_metadata_type "$meta_file")
            printf '%s\t%s\n' "$mtype" "$version" >> "$RAW_DATA"
        fi
    fi
done < <(find "$SRC_DIR" -type f \( -name "*.cls" -o -name "*.trigger" -o -name "*.page" -o -name "*.component" \) -print0)

# For .flow-meta.xml files
while IFS= read -r -d '' file; do
    version=$(extract_api_version "$file")
    if [[ -n "$version" ]]; then
        mtype=$(classify_metadata_type "$file")
        printf '%s\t%s\n' "$mtype" "$version" >> "$RAW_DATA"
    fi
done < <(find "$SRC_DIR" -type f -name "*.flow-meta.xml" -print0)

# For LWC and Aura component meta files (js-meta.xml, cmp-meta.xml, app-meta.xml, etc.)
while IFS= read -r -d '' file; do
    # Skip files already captured above
    case "$file" in
        *.cls-meta.xml|*.trigger-meta.xml|*.page-meta.xml|*.component-meta.xml|*.flow-meta.xml) continue ;;
    esac
    version=$(extract_api_version "$file")
    if [[ -n "$version" ]]; then
        mtype=$(classify_metadata_type "$file")
        printf '%s\t%s\n' "$mtype" "$version" >> "$RAW_DATA"
    fi
done < <(find "$SRC_DIR" -type f -name "*-meta.xml" -print0)

total_count=$(wc -l < "$RAW_DATA" | tr -d ' ')
if [[ "$total_count" -eq 0 ]]; then
    echo "WARNING: No metadata files with API versions found."
    exit 0
fi

echo "Found $total_count components with API versions."

# Collect unique metadata types and API versions (sorted)
mapfile -t MTYPES < <(cut -f1 "$RAW_DATA" | sort -u)
mapfile -t VERSIONS < <(cut -f2 "$RAW_DATA" | sort -t. -k1,1n -k2,2n | uniq)

# Build the CSV
{
#    echo "# Salesforce Metadata API Version Audit Report"
#    echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
#    echo "# Source Directory: $SRC_DIR"
#    echo "#"

    # Header row
    header="Metadata Type"
    for v in "${VERSIONS[@]}"; do
        header+=",API $v"
    done
    header+=",Total"
    echo "$header"

    # Grand totals array
    declare -A grand_totals
    for v in "${VERSIONS[@]}"; do
        grand_totals["$v"]=0
    done
    grand_total=0

    # Data rows
    for mtype in "${MTYPES[@]}"; do
        row="$mtype"
        row_total=0
        for v in "${VERSIONS[@]}"; do
            count=$(awk -F'\t' -v mt="$mtype" -v ver="$v" '$1==mt && $2==ver' "$RAW_DATA" | wc -l | tr -d ' ')
            row+=",$count"
            row_total=$((row_total + count))
            grand_totals["$v"]=$((${grand_totals["$v"]} + count))
        done
        row+=",$row_total"
        grand_total=$((grand_total + row_total))
        echo "$row"
    done

    # Totals row
    totals_row="TOTAL"
    for v in "${VERSIONS[@]}"; do
        totals_row+=",${grand_totals[$v]}"
    done
    totals_row+=",$grand_total"
    echo "$totals_row"

} > "$OUTPUT_FILE"

echo "Audit complete. Report saved to: $OUTPUT_FILE"
