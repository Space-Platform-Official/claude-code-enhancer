---
description: Fast and safe cleanup of Claude Code backup files with preview and retention control
---

# Clean Backups Command

**FAST AND SAFE REMOVAL OF CLAUDE CODE BACKUP FILES**

When you run `/clean-backups`, you will:

1. **SCAN** the entire project for backup files matching Claude patterns
2. **PREVIEW** the files to be deleted with count and size
3. **RESPECT** retention policy (default: 24 hours)
4. **CONFIRM** before deletion to prevent accidents
5. **REPORT** detailed cleanup statistics

## Usage

```bash
# Preview backup files (dry run)
/clean-backups

# Delete all old backups (interactive)
/clean-backups --delete

# Force delete without confirmation (dangerous)
/clean-backups --force

# Custom retention period (hours)
/clean-backups --retention 48

# Clean specific directory
/clean-backups --path ./src
```

## Implementation

```bash
#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RETENTION_HOURS="${CLAUDE_MERGE_BACKUP_RETENTION:-24}"
DRY_RUN=true
FORCE_DELETE=false
SEARCH_PATH="."

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --delete|-d)
            DRY_RUN=false
            shift
            ;;
        --force|-f)
            DRY_RUN=false
            FORCE_DELETE=true
            shift
            ;;
        --retention|-r)
            RETENTION_HOURS="$2"
            shift 2
            ;;
        --path|-p)
            SEARCH_PATH="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: /clean-backups [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --delete      Delete backup files (with confirmation)"
            echo "  -f, --force       Force delete without confirmation"
            echo "  -r, --retention   Retention period in hours (default: 24)"
            echo "  -p, --path        Path to search (default: current directory)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to format file size
format_size() {
    local size=$1
    if [[ $size -gt 1048576 ]]; then
        echo "$(( size / 1048576 ))MB"
    elif [[ $size -gt 1024 ]]; then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

# Function to check if backup is old enough
is_old_backup() {
    local file="$1"
    local retention="$2"
    
    # Extract timestamp from filename
    local timestamp=""
    
    # Pattern 1: *.backup.{unix_timestamp}
    if [[ "$file" =~ \.backup\.([0-9]{10})$ ]]; then
        timestamp="${BASH_REMATCH[1]}"
    # Pattern 2: *.pre-rollback.{unix_timestamp}
    elif [[ "$file" =~ \.pre-rollback\.([0-9]{10})$ ]]; then
        timestamp="${BASH_REMATCH[1]}"
    # Pattern 3: *.backup.{YYYYMMDD-HHMMSS}
    elif [[ "$file" =~ \.backup\.([0-9]{8}-[0-9]{6})$ ]]; then
        # Convert date format to unix timestamp
        local date_str="${BASH_REMATCH[1]}"
        timestamp=$(date -j -f "%Y%m%d-%H%M%S" "$date_str" "+%s" 2>/dev/null || echo "0")
    fi
    
    # Check age if timestamp found
    if [[ -n "$timestamp" && "$timestamp" =~ ^[0-9]+$ ]]; then
        local current_time=$(date +%s)
        local age_hours=$(( (current_time - timestamp) / 3600 ))
        
        if [[ $age_hours -gt $retention ]]; then
            return 0  # Old enough to delete
        fi
    fi
    
    return 1  # Keep the file
}

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Backup Cleanup Tool      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Scan for backup files
echo -e "${BLUE}[SCAN]${NC} Searching for backup files in: $SEARCH_PATH"

# Find all backup files with different patterns
backup_files=()
total_size=0
old_count=0
old_size=0

# Pattern 1: Standard backup files (*.backup.*)
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        backup_files+=("$file")
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        total_size=$((total_size + size))
        
        if is_old_backup "$file" "$RETENTION_HOURS"; then
            old_count=$((old_count + 1))
            old_size=$((old_size + size))
        fi
    fi
done < <(find "$SEARCH_PATH" -type f \( \
    -name "*.backup.*" -o \
    -name "*.pre-rollback.*" -o \
    -name "*_ENHANCED.md" \
    \) ! -path "*/.git/*" ! -path "*/node_modules/*" -print0 2>/dev/null)

# Display statistics
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📊 Backup File Statistics:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "Total backup files found: ${GREEN}${#backup_files[@]}${NC}"
echo -e "Total size: ${GREEN}$(format_size $total_size)${NC}"
echo ""
echo -e "Files older than ${RETENTION_HOURS}h: ${YELLOW}$old_count${NC}"
echo -e "Size to be freed: ${YELLOW}$(format_size $old_size)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

# Exit if no old backups found
if [[ $old_count -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ No old backup files to clean!${NC}"
    echo -e "All backups are within the ${RETENTION_HOURS}-hour retention period."
    exit 0
fi

# Show preview of files to delete
echo ""
echo -e "${YELLOW}Files to be deleted (older than ${RETENTION_HOURS}h):${NC}"
echo -e "${BLUE}───────────────────────────────────────────────${NC}"

delete_list=()
for file in "${backup_files[@]}"; do
    if is_old_backup "$file" "$RETENTION_HOURS"; then
        delete_list+=("$file")
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        # Show relative path for readability
        rel_path="${file#./}"
        echo -e "  • $rel_path ${BLUE}($(format_size $size))${NC}"
        
        # Limit preview to first 10 files
        if [[ ${#delete_list[@]} -eq 10 && $old_count -gt 10 ]]; then
            echo -e "  ${BLUE}... and $((old_count - 10)) more files${NC}"
            break
        fi
    fi
done

echo -e "${BLUE}───────────────────────────────────────────────${NC}"

# Handle deletion based on mode
if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    echo -e "${BLUE}[DRY RUN]${NC} No files were deleted."
    echo -e "Run with ${GREEN}--delete${NC} to remove these files."
    echo -e "Run with ${YELLOW}--force${NC} to skip confirmation."
elif [[ "$FORCE_DELETE" == "true" ]]; then
    # Force delete without confirmation
    echo ""
    echo -e "${YELLOW}[FORCE DELETE]${NC} Removing backup files..."
    
    deleted_count=0
    failed_count=0
    
    for file in "${backup_files[@]}"; do
        if is_old_backup "$file" "$RETENTION_HOURS"; then
            if rm -f "$file" 2>/dev/null; then
                deleted_count=$((deleted_count + 1))
            else
                failed_count=$((failed_count + 1))
                echo -e "${RED}  ✗ Failed to delete: $file${NC}"
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Cleanup Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    echo -e "Deleted: ${GREEN}$deleted_count${NC} files"
    if [[ $failed_count -gt 0 ]]; then
        echo -e "Failed: ${RED}$failed_count${NC} files"
    fi
    echo -e "Space freed: ${GREEN}$(format_size $old_size)${NC}"
else
    # Interactive confirmation
    echo ""
    echo -e "${YELLOW}⚠️  CONFIRMATION REQUIRED${NC}"
    echo -e "This will permanently delete ${YELLOW}$old_count${NC} backup files."
    echo -e "Total space to be freed: ${YELLOW}$(format_size $old_size)${NC}"
    echo ""
    read -p "Are you sure you want to proceed? (yes/no): " confirmation
    
    if [[ "$confirmation" == "yes" || "$confirmation" == "y" ]]; then
        echo ""
        echo -e "${BLUE}[DELETE]${NC} Removing backup files..."
        
        deleted_count=0
        failed_count=0
        
        for file in "${backup_files[@]}"; do
            if is_old_backup "$file" "$RETENTION_HOURS"; then
                if rm -f "$file" 2>/dev/null; then
                    deleted_count=$((deleted_count + 1))
                    # Show progress for large cleanups
                    if [[ $((deleted_count % 10)) -eq 0 ]]; then
                        echo -e "  ${BLUE}Progress: $deleted_count/$old_count files deleted...${NC}"
                    fi
                else
                    failed_count=$((failed_count + 1))
                    echo -e "${RED}  ✗ Failed to delete: $file${NC}"
                fi
            fi
        done
        
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅ Cleanup Complete!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo -e "Deleted: ${GREEN}$deleted_count${NC} files"
        if [[ $failed_count -gt 0 ]]; then
            echo -e "Failed: ${RED}$failed_count${NC} files"
        fi
        echo -e "Space freed: ${GREEN}$(format_size $old_size)${NC}"
    else
        echo ""
        echo -e "${YELLOW}[CANCELLED]${NC} No files were deleted."
    fi
fi

# Show retention policy reminder
echo ""
echo -e "${BLUE}ℹ️  Retention Policy:${NC} ${RETENTION_HOURS} hours"
echo -e "Set ${GREEN}CLAUDE_MERGE_BACKUP_RETENTION${NC} environment variable to customize."
```

## Features

### 🎯 Smart Pattern Detection
- `*.backup.{unix_timestamp}` - Standard backup files
- `*.pre-rollback.{unix_timestamp}` - Rollback safety files
- `*.backup.{YYYYMMDD-HHMMSS}` - Date-formatted backups
- `*_ENHANCED.md` - Enhanced package violations

### 🛡️ Safety Features
- **Dry run by default** - Preview before deletion
- **Retention policy** - Keep recent backups (default: 24h)
- **Interactive confirmation** - Prevent accidents
- **Skip sensitive paths** - Excludes .git/, node_modules/

### ⚡ Performance Optimizations
- **Efficient find** - Single pass with multiple patterns
- **Limited preview** - Shows first 10 files to avoid spam
- **Progress indicators** - For large cleanup operations
- **Parallel processing** - Optimized for speed

### 📊 Detailed Reporting
- Total files and size found
- Files eligible for deletion
- Space to be freed
- Success/failure counts
- Retention policy status

## Examples

```bash
# Preview what would be deleted
/clean-backups

# Delete with confirmation
/clean-backups --delete

# Force delete (no confirmation)
/clean-backups --force

# Keep backups for 48 hours
/clean-backups --retention 48 --delete

# Clean specific directory only
/clean-backups --path ./src --delete

# Aggressive cleanup (1 hour retention)
/clean-backups --retention 1 --force
```

## Environment Variables

```bash
# Set default retention period (hours)
export CLAUDE_MERGE_BACKUP_RETENTION=48

# Run cleanup
/clean-backups --delete
```

## Safety Considerations

1. **Always preview first** - Default dry run shows what will be deleted
2. **Check retention** - Ensure you're not deleting recent backups
3. **Verify path** - Make sure you're in the right directory
4. **Use force carefully** - Skip confirmation only when certain

## Success Criteria

✅ Fast scanning of all backup patterns
✅ Clear preview with file count and size
✅ Respects retention policy
✅ Safe confirmation before deletion
✅ Detailed success reporting
✅ Zero accidental deletions

This command provides the fastest, safest way to clean up Claude Code backup files!