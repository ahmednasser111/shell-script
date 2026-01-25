#!/bin/bash

table_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}=== Table Menu ===${NC}"
        echo ""
        echo "  1. Create Table"
        echo "  2. List Tables"
        echo "  3. Drop Table"
        echo "  4. Insert into Table"
        echo "  5. Select From Table"
        echo "  6. Delete From Table"
        echo "  7. Update Table"
        echo "  8. Back to Main Menu"
        echo ""
        
        read -p "Enter your choice [1-8]: " choice
        
        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) 
                CURRENT_DB=""
                return
                ;;
            *)
                print_error "Invalid choice."
                press_any_key
                ;;
        esac
    done
}

main_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}=== Main Menu ===${NC}"
        echo ""
        echo "  1. Create Database"
        echo "  2. List Databases"
        echo "  3. Connect to Database"
        echo "  4. Drop Database"
        echo "  5. Exit"
        echo ""
        
        read -p "Enter your choice [1-5]: " choice
        
        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5)
                print_header
                print_info "Thank you for using Bash DBMS. Goodbye!"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid choice."
                press_any_key
                ;;
        esac
    done
}
