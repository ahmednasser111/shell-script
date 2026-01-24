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
