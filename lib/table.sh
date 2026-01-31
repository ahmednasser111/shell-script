#!/bin/bash

get_table_path() {
    echo "$DB_DIR/$CURRENT_DB/$1"
}

get_meta_path() {
    echo "$DB_DIR/$CURRENT_DB/$1.meta"
}

create_table() {
    print_header
    echo -e "${YELLOW}=== Create Table ===${NC}"
    echo ""
    
    read -p "Enter table name: " table_name
    local table_path=$(get_table_path "$table_name")
    local meta_path=$(get_meta_path "$table_name")
    
    read -p "Enter number of columns: " num_cols
    
    local meta_content=""
    local pk_set=false
    
    echo ""
    echo "Define columns (datatypes: int, string, date):"
    echo "-----------------------------------------------"
    
    for ((i=1; i<=num_cols; i++)); do
        echo ""
        echo "Column $i:"
        read -p "  Name: " col_name
        read -p "  Datatype (int/string/date): " col_type
        
        local is_pk=""
        if [[ "$pk_set" == false ]]; then
            read -p "  Is this the primary key? (y/n): " pk_choice
            [[ "$pk_choice" == "y" || "$pk_choice" == "Y" ]] && is_pk=":pk" && pk_set=true
        fi
        
        [[ -n "$meta_content" ]] && meta_content+="\n"
        meta_content+="$col_name:$col_type$is_pk"
    done
    
    touch "$table_path"
    echo -e "$meta_content" > "$meta_path"
    print_success "Table '$table_name' created."
    press_any_key
}

list_tables() {
    print_header
    echo -e "${YELLOW}=== List Tables ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    press_any_key
}

drop_table() {
    print_header
    echo -e "${YELLOW}=== Drop Table ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    
    echo ""
    read -p "Enter table name to drop: " table_name
    rm -f "$(get_table_path "$table_name")" "$(get_meta_path "$table_name")"
    print_success "Table '$table_name' dropped."
    press_any_key
}


check_pk_unique() {
    local table_path=$1
    local pk_index=$2
    local pk_value=$3
    
    [[ ! -s "$table_path" ]] && return 0
    
    while IFS= read -r line; do
        local current_pk=$(echo "$line" | cut -d"$DELIMITER" -f$((pk_index + 1)))
        [[ "$current_pk" == "$pk_value" ]] && return 1
    done < "$table_path"
    
    return 0
}

insert_into_table() {
    print_header
    echo -e "${YELLOW}=== Insert Into Table ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    
    echo ""
    read -p "Enter table name: " table_name
    local table_path=$(get_table_path "$table_name")
    local meta_path=$(get_meta_path "$table_name")
    
    local -a col_names col_types
    local pk_index
    read_schema "$meta_path" col_names col_types pk_index
    
    echo ""
    echo "Enter values for each column:"
    echo "------------------------------"
    
    local row_data=""
    local pk_value=""
    
    for ((i=0; i<${#col_names[@]}; i++)); do
        local col_name="${col_names[$i]}"
        local col_type="${col_types[$i]}"
        local prompt="  $col_name ($col_type"
        [[ $i -eq $pk_index ]] && prompt+=", PK"
        prompt+="): "
        
        read -p "$prompt" value
        [[ $i -eq $pk_index ]] && pk_value="$value"
        
        [[ -n "$row_data" ]] && row_data+="$DELIMITER"
        row_data+="$value"
    done
    
    echo "$row_data" >> "$table_path"
    print_success "Row inserted."
    press_any_key
}

format_table_output() {
    local table_path=$1
    local meta_path=$2
    
    local headers=()
    local col_widths=()
    
    while IFS= read -r line; do
        local col_name=$(echo "$line" | cut -d':' -f1)
        headers+=("$col_name")
        col_widths+=(${#col_name})
    done < "$meta_path"
    
    local num_cols=${#headers[@]}
    
    if [[ -s "$table_path" ]]; then
        while IFS= read -r line; do
            for ((i=0; i<num_cols; i++)); do
                local value=$(echo "$line" | cut -d"$DELIMITER" -f$((i + 1)))
                local value_len=${#value}
                if [[ $value_len -gt ${col_widths[$i]} ]]; then
                    col_widths[$i]=$value_len
                fi
            done
        done < "$table_path"
    fi
    
    print_separator() {
        echo -n "+"
        for ((i=0; i<num_cols; i++)); do
            printf '%*s' $((col_widths[$i] + 2)) '' | tr ' ' '-'
            echo -n "+"
        done
        echo ""
    }
    
    print_separator
    echo -n "|"
    for ((i=0; i<num_cols; i++)); do
        printf " %-${col_widths[$i]}s |" "${headers[$i]}"
    done
    echo ""
    print_separator
    
    if [[ -s "$table_path" ]]; then
        while IFS= read -r line; do
            echo -n "|"
            for ((i=0; i<num_cols; i++)); do
                local value=$(echo "$line" | cut -d"$DELIMITER" -f$((i + 1)))
                printf " %-${col_widths[$i]}s |" "$value"
            done
            echo ""
        done < "$table_path"
    fi
    print_separator
}

select_from_table() {
    print_header
    echo -e "${YELLOW}=== Select From Table ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    
    echo ""
    read -p "Enter table name: " table_name
    local table_path=$(get_table_path "$table_name")
    local meta_path=$(get_meta_path "$table_name")
    
    echo ""
    format_table_output "$table_path" "$meta_path"
    
    local row_count=0
    [[ -s "$table_path" ]] && row_count=$(wc -l < "$table_path")
    echo ""
    print_info "Total rows: $row_count"
    
    press_any_key
}

delete_from_table() {
    print_header
    echo -e "${YELLOW}=== Delete From Table ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    
    echo ""
    read -p "Enter table name: " table_name
    local table_path=$(get_table_path "$table_name")
    local meta_path=$(get_meta_path "$table_name")
    
    echo ""
    echo "Current data:"
    format_table_output "$table_path" "$meta_path"
    
    local -a col_names col_types
    local pk_index
    read_schema "$meta_path" col_names col_types pk_index
    local pk_col="${col_names[$pk_index]}"
    
    echo ""
    read -p "Enter $pk_col value to delete: " pk_value
    
    local temp_file=$(mktemp)
    trap "rm -f '$temp_file'" RETURN
    local deleted=false
    
    while IFS= read -r line; do
        local current_pk=$(echo "$line" | cut -d"$DELIMITER" -f$((pk_index + 1)))
        if [[ "$current_pk" == "$pk_value" ]]; then
            deleted=true
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$table_path"
    
    mv "$temp_file" "$table_path"
    print_success "Row deleted."
    press_any_key
}

update_table() {
    print_header
    echo -e "${YELLOW}=== Update Table ===${NC}"
    echo ""
    
    local db_path="$DB_DIR/$CURRENT_DB"
    select_from_list "$db_path" "*.meta" "tables"
    
    echo ""
    read -p "Enter table name: " table_name
    local table_path=$(get_table_path "$table_name")
    local meta_path=$(get_meta_path "$table_name")
    
    echo ""
    echo "Current data:"
    format_table_output "$table_path" "$meta_path"
    
    local -a col_names col_types
    local pk_index
    read_schema "$meta_path" col_names col_types pk_index
    local pk_col="${col_names[$pk_index]}"
    
    echo ""
    read -p "Enter $pk_col value of row to update: " pk_value
    
    local row_found=""
    local line_num=1
    local found_line=0
    
    while IFS= read -r line; do
        local current_pk=$(echo "$line" | cut -d"$DELIMITER" -f$((pk_index + 1)))
        if [[ "$current_pk" == "$pk_value" ]]; then
            row_found="$line"
            found_line=$line_num
            break
        fi
        ((line_num++))
    done < "$table_path"
    
    echo ""
    echo "Select column to update:"
    echo "------------------------"
    for ((i=0; i<${#col_names[@]}; i++)); do
        if [[ $i -ne $pk_index ]]; then
            local current_val=$(echo "$row_found" | cut -d"$DELIMITER" -f$((i + 1)))
            echo "  $((i + 1)). ${col_names[$i]} (current: $current_val)"
        fi
    done
    
    echo ""
    read -p "Enter column number to update: " col_num
    
    local target_index=$((col_num - 1))
    local target_col="${col_names[$target_index]}"
    local target_type="${col_types[$target_index]}"
    
    read -p "Enter new value for $target_col ($target_type): " new_value
    
    local new_row=""
    for ((i=0; i<${#col_names[@]}; i++)); do
        [[ $i -gt 0 ]] && new_row+="$DELIMITER"
        if [[ $i -eq $target_index ]]; then
            new_row+="$new_value"
        else
            new_row+=$(echo "$row_found" | cut -d"$DELIMITER" -f$((i + 1)))
        fi
    done
    
    local temp_file=$(mktemp)
    trap "rm -f '$temp_file'" RETURN
    local current_line=1
    
    while IFS= read -r line; do
        if [[ $current_line -eq $found_line ]]; then
            echo "$new_row" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
        ((current_line++))
    done < "$table_path"
    
    mv "$temp_file" "$table_path"
    print_success "Row updated."
    press_any_key
}
