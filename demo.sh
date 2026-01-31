#!/bin/bash


source lib/config.sh
source lib/utils.sh
source lib/database.sh
source lib/table.sh

init_db_dir

echo "Creating sample databases and tables..."
echo ""

# Create company database
mkdir -p "$DB_DIR/company"

# Create employees table
echo "emp_id:int" > "$DB_DIR/company/employees.meta"
echo "name:string" >> "$DB_DIR/company/employees.meta"
echo "salary:int" >> "$DB_DIR/company/employees.meta"
echo "department:string:pk" >> "$DB_DIR/company/employees.meta"

touch "$DB_DIR/company/employees"
echo "E001:Alice:75000:IT" >> "$DB_DIR/company/employees"
echo "E002:Bob:65000:HR" >> "$DB_DIR/company/employees"
echo "E003:Charlie:80000:IT" >> "$DB_DIR/company/employees"
echo "E004:Diana:70000:Sales" >> "$DB_DIR/company/employees"

# Create departments table
touch "$DB_DIR/company/departments"
echo "dept_id:string:pk" > "$DB_DIR/company/departments.meta"
echo "dept_name:string" >> "$DB_DIR/company/departments.meta"
echo "budget:int" >> "$DB_DIR/company/departments.meta"

echo "IT:Information Technology:500000" >> "$DB_DIR/company/departments"
echo "HR:Human Resources:200000" >> "$DB_DIR/company/departments"
echo "Sales:Sales Department:300000" >> "$DB_DIR/company/departments"

# Create school database
mkdir -p "$DB_DIR/school"

# Create students table
touch "$DB_DIR/school/students"
echo "student_id:int:pk" > "$DB_DIR/school/students.meta"
echo "name:string" >> "$DB_DIR/school/students.meta"
echo "grade:string" >> "$DB_DIR/school/students.meta"
echo "age:int" >> "$DB_DIR/school/students.meta"

echo "1001:Ahmed:A:16" >> "$DB_DIR/school/students"
echo "1002:Fatima:B:16" >> "$DB_DIR/school/students"
echo "1003:Hassan:A:17" >> "$DB_DIR/school/students"
echo "1004:Noor:A:16" >> "$DB_DIR/school/students"
echo "1005:Youssef:C:17" >> "$DB_DIR/school/students"

# Create courses table
touch "$DB_DIR/school/courses"
echo "course_id:int:pk" > "$DB_DIR/school/courses.meta"
echo "course_name:string" >> "$DB_DIR/school/courses.meta"
echo "instructor:string" >> "$DB_DIR/school/courses.meta"
echo "credits:int" >> "$DB_DIR/school/courses.meta"

echo "101:Mathematics:Dr. Smith:3" >> "$DB_DIR/school/courses"
echo "102:English:Ms. Johnson:3" >> "$DB_DIR/school/courses"
echo "103:Physics:Prof. Brown:4" >> "$DB_DIR/school/courses"
echo "104:Chemistry:Dr. Lee:4" >> "$DB_DIR/school/courses"

# Create shop database
mkdir -p "$DB_DIR/shop"

# Create products table
touch "$DB_DIR/shop/products"
echo "product_id:int:pk" > "$DB_DIR/shop/products.meta"
echo "name:string" >> "$DB_DIR/shop/products.meta"
echo "price:int" >> "$DB_DIR/shop/products.meta"
echo "stock:int" >> "$DB_DIR/shop/products.meta"

echo "1:Laptop:1200:15" >> "$DB_DIR/shop/products"
echo "2:Mouse:25:100" >> "$DB_DIR/shop/products"
echo "3:Keyboard:75:50" >> "$DB_DIR/shop/products"
echo "4:Monitor:300:20" >> "$DB_DIR/shop/products"
echo "5:USB Cable:10:500" >> "$DB_DIR/shop/products"

# Create orders table
touch "$DB_DIR/shop/orders"
echo "order_id:int:pk" > "$DB_DIR/shop/orders.meta"
echo "customer:string" >> "$DB_DIR/shop/orders.meta"
echo "product_id:int" >> "$DB_DIR/shop/orders.meta"
echo "quantity:int" >> "$DB_DIR/shop/orders.meta"
echo "total:int" >> "$DB_DIR/shop/orders.meta"

echo "1001:John:1:2:2400" >> "$DB_DIR/shop/orders"
echo "1002:Sarah:3:1:75" >> "$DB_DIR/shop/orders"
echo "1003:Mike:2:5:125" >> "$DB_DIR/shop/orders"
echo "1004:Emma:4:3:900" >> "$DB_DIR/shop/orders"

echo ""
print_success "Demo data created successfully!"
echo ""
echo "Databases created:"
echo "  - company (employees, departments)"
echo "  - school (students, courses)"
echo "  - shop (products, orders)"
echo ""
echo "Run './dbms.sh' to explore the data!"

