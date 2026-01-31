#!/bin/bash

init_db_dir() {
    if [[ ! -d "$DB_DIR" ]]; then
        mkdir -p "$DB_DIR"
    fi
}

# Parse schema file and build column metadata arrays
# Returns: col_names, col_types, pk_index, pk_name
read_schema() {
    local meta_path=$1
    local -n cols=$2
    local -n types=$3
    local -n pk_idx=$4
    
    local idx=0
    pk_idx=-1
    
    while IFS=':' read -r name type rest; do
        cols+=("$name")
        types+=("${type%:pk}")
        [[ "$rest" == "pk" ]] && pk_idx=$idx
        ((idx++))
    done < "$meta_path"
}

# Get index of column by name
get_column_index() {
    local meta_path=$1
    local col_name=$2
    local idx=0
    
    while IFS=':' read -r name rest; do
        [[ "$name" == "$col_name" ]] && echo "$idx" && return 0
        ((idx++))
    done < "$meta_path"
    
    echo "-1"
    return 1
}

create_database() {
    print_header
    echo -e "${YELLOW}=== Create Database ===${NC}"
    echo ""
    
    read -p "Enter database name: " db_name
    mkdir -p "$DB_DIR/$db_name"
    print_success "Database '$db_name' created."
    press_any_key
}

list_databases() {
    print_header
    echo -e "${YELLOW}=== List Databases ===${NC}"
    echo ""
    
    select_from_list "$DB_DIR" "" "databases"
    press_any_key
}

connect_database() {
    print_header
    echo -e "${YELLOW}=== Connect to Database ===${NC}"
    echo ""
    
    select_from_list "$DB_DIR" "" "databases"
    echo ""
    read -p "Enter database name: " db_name
    CURRENT_DB="$db_name"
    print_success "Connected to database '$db_name'."
    press_any_key
    table_menu
}

drop_database() {
    print_header
    echo -e "${YELLOW}=== Drop Database ===${NC}"
    echo ""
    
    select_from_list "$DB_DIR" "" "databases"
    echo ""
    read -p "Enter database name to drop: " db_name
    rm -rf "$DB_DIR/$db_name"
    print_success "Database '$db_name' dropped."
    [[ "$CURRENT_DB" == "$db_name" ]] && CURRENT_DB=""
    press_any_key
}

