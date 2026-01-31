#!/bin/bash

# Print colored message
print_msg() {
    local color=$1
    local msg=$2
    echo -e "${color}${msg}${NC}"
}

print_success() {
    print_msg "$GREEN" "✓ $1"
}

print_error() {
    print_msg "$RED" "✗ $1"
}

print_info() {
    print_msg "$CYAN" "ℹ $1"
}

print_warning() {
    print_msg "$YELLOW" "⚠ $1"
}

validate_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        return 1
    fi
    if [[ "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_int() {
    local value=$1
    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_date() {
    local value=$1
    if [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_string() {
    local value=$1
    if [[ -z "$value" ]]; then
        return 1
    fi
    if [[ "$value" == *"$DELIMITER"* ]]; then
        return 1
    fi
    return 0
}

validate_value() {
    local value=$1
    local datatype=$2
    
    case "$datatype" in
        "int")
            validate_int "$value"
            return $?
            ;;
        "string")
            validate_string "$value"
            return $?
            ;;
        "date")
            validate_date "$value"
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

print_header() {
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}       Bash Shell Script Database Management System${NC}"
    echo -e "${BLUE}============================================================${NC}"
    if [[ -n "$CURRENT_DB" ]]; then
        echo -e "${CYAN}       Current Database: ${YELLOW}$CURRENT_DB${NC}"
        echo -e "${BLUE}============================================================${NC}"
    fi
    echo ""
}

press_any_key() {
    echo ""
    read -p "Press Enter to continue..."
}

# List items from directory and return selected item
# Usage: select_from_list "$dir_path" "*.meta" "Item Type"
select_from_list() {
    local dir_path=$1
    local exclude_pattern=$2
    local item_type=$3
    
    if [[ ! -d "$dir_path" ]] || [[ -z "$(ls -A "$dir_path" 2>/dev/null)" ]]; then
        return 1
    fi
    
    local -a items
    local count=0
    for item in "$dir_path"/*; do
        if [[ -f "$item" ]]; then
            [[ "$exclude_pattern" != "" && "$item" == $exclude_pattern ]] && continue
        fi
        items+=("$(basename "$item")")
    done
    
    if [[ ${#items[@]} -eq 0 ]]; then
        return 1
    fi
    
    echo "Available $item_type:"
    echo "$(printf '%0.s-' {1..25})"
    for ((i=0; i<${#items[@]}; i++)); do
        echo "  $((i+1)). ${items[$i]}"
    done
    echo ""
    
    return 0
}

# Get table files from database directory (excludes .meta files)
get_table_files() {
    local db_path=$1
    for file in "$db_path"/*; do
        if [[ -f "$file" && ! "$file" == *.meta ]]; then
            basename "$file"
        fi
    done
}

# Prompt for input with validation and retry
prompt_validated() {
    local prompt=$1
    local validator=$2
    local max_attempts=3
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        read -p "$prompt" input
        if $validator "$input"; then
            echo "$input"
            return 0
        fi
        ((attempt++))
        if [[ $attempt -lt $max_attempts ]]; then
            print_warning "Invalid input. Try again ($((max_attempts - attempt)) attempts left)."
        fi
    done
    
    print_error "Too many invalid attempts."
    return 1
}

