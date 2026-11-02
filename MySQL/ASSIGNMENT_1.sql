-- question 1

create database employee;
use employee;
create table departments(department_id int primary key,
                          department_name varchar(100));
create table location(location_id int primary key,
					   location varchar(30));
create table employees(employee_id int primary key,
					   employee_name varchar(50),
                       gender enum('M','F'),
                       age int,
                       hire_date date,
                       designation varchar(100),
                       department_id int,
                       location_id int,
                       salary decimal(10,2));
show databases;
show tables;
desc departments;
desc location;
desc employees;

-- question 2
-- a
alter table employees add column(email varchar(20));
desc employees;

-- b
alter table employees modify designation varchar(150);
desc employees;

-- c
alter table employees drop column age;
desc employees;

-- d
alter table employees rename column hire_date to date_of_joining;
desc employees;

-- question 3
-- a
rename table departments to department_info;
show tables;

-- b
rename table location to locations;
show tables;

-- question 4
-- a
truncate table employees;
show tables;

-- question 5
drop table employees;
drop database employee;

show tables;
show databases;

-- consatraints
-- 1
create database employee;
use employee;

-- 2
create table departments(department_id int primary key,
                          department_name varchar(100) not null unique);
desc departments;

-- 3
create table location(location_id int primary key auto_increment,
					   location varchar(30) unique not null);
desc location;


-- 4
create table employees(employee_id int primary key,
					   employee_name varchar(50) not null,
                       gender enum('M','F'),
                       age int check(age>=18),
                       hire_date date default(current_date()),
                       designation varchar(100),
                       department_id int,
                       location_id int,
                       salary decimal(10,2),
                       foreign key(department_id) references departments(department_id),
                       foreign key(location_id) references location(location_id));
desc employees;

                       
                       




                       
                          