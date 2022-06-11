-- Charles Denney
-- Lab1
-- Advanced Databases 
-- COP 4703
-- 2022/06/10

-- TASK 1: create database and tables

CREATE DATABASE Lab1;

USE Lab1;

CREATE TABLE Dept(
deptName		VARCHAR(20) PRIMARY KEY,
mgrID			INT
);

create table Worker(
empID			INT			PRIMARY KEY,
empLastname		VARCHAR(20),
empFirstName	VARCHAR(20),
deptName		VARCHAR(20)	FOREIGN KEY REFERENCES Dept(deptName),
birthdate		DATE,
dateHired		DATE,
salary			NUMERIC(10,2)
);
ALTER TABLE Dept ADD CONSTRAINT Dept_deptID_fk FOREIGN KEY (mgrID) REFERENCES Worker(empID);

CREATE TABLE Project(
projNo			INT			PRIMARY KEY,
projName		varchar(20),
projMgrID		INT			FOREIGN KEY REFERENCES Worker(empID),
budget			NUMERIC(10,2),
startDate		DATE,
expectedDurationWeeks	NUMERIC(4)
);

create Table Assign(
projNo			INT,
empID			INT,
hoursAssigned	NUMERIC(3),
rating			NUMERIC(1)
CONSTRAINT Assign_projNoempID_pk PRIMARY KEY(projNo, empID),
CONSTRAINT Assign_projNo_fk FOREIGN KEY(projNo) REFERENCES Project(projNo),
CONSTRAINT Assign_empID_fk FOREIGN KEY(empID)	REFERENCES Worker(empID)
);

-- TASK 2: populate database

INSERT INTO Dept VALUES ('Accounting',null);
INSERT INTO Dept VALUES ('Research',null);

INSERT INTO Worker VALUES(101,'Smith','Tom', 'Accounting', '01-Feb-1970', '06-Jun-1993 ',50000);
INSERT INTO Worker VALUES(103,'Jones','Mary','Accounting', '15-Jun-1975', '20-Sep-2005',48000);
INSERT INTO Worker VALUES(105,'Burns','Jane','Accounting', '21-Sep-1980', '12-Jun-2000',39000);
INSERT INTO Worker VALUES(110,'Burns','Michael', 'Research', '05-Apr-1977', '10-Sep-2010',70000);
INSERT INTO Worker VALUES(115,'Chin','Amanda', 'Research', '22-Sep-1980', '19-Jun-2014',60000);

UPDATE Dept SET mgrId = 101 WHERE deptName = 'Accounting';
UPDATE Dept SET mgrId = 110 WHERE deptName = 'Research';
INSERT INTO Project VALUES (1001, 'Jupiter', 101, 300000, '01-Feb-2014', 50);
INSERT INTO Project VALUES (1005, 'Saturn', 101, 400000, '01-Jun-2014', 35);
INSERT INTO Project VALUES (1019, 'Mercury', 110, 350000, '15-Feb-2014', 40);
INSERT INTO Project VALUES (1025, 'Neptune', 110, 600000, '01-Feb-2015', 45);
INSERT INTO Project VALUES (1030, 'Pluto', 110, 380000, '15-Sep-2014', 50);

INSERT INTO Assign VALUES(1001, 101, 30,null);
INSERT INTO Assign VALUES(1001, 103, 20,5);
INSERT INTO Assign VALUES(1005, 103, 20,null);
INSERT INTO Assign VALUES(1001, 105, 30,null);
INSERT INTO Assign VALUES(1001, 115, 20,4);
INSERT INTO Assign VALUES(1019, 110, 20,5);
INSERT INTO Assign VALUES(1019, 115, 10,4);
INSERT INTO Assign VALUES(1025, 110, 10,null);
INSERT INTO Assign VALUES(1030, 110, 10,null);

-- TASK 3: execute queries

-- Get the names of all workers in the Accounting department.

SELECT empLastname, empFirstName
FROM Worker
WHERE deptname = 'Accounting';

-- Get an alphabetical list of names of all workers assigned to project 1001.

SELECT empLastname, empFirstName
FROM Worker
WHERE empID IN
	(SELECT empID
	FROM Assign
	WHERE projNo = '1001')
ORDER BY empLastname;

-- Get the name of the employee in the Research department who has the lowest salary.

SELECT empLastName, empFirstName, salary
FROM Worker
WHERE salary IN
	(SELECT MIN(salary)
	FROM Worker);

-- Get details of the project with the highest budget.

SELECT *
FROM Project
WHERE budget IN
	(SELECT MAX(budget)
	FROM Project);

-- Get the names and departments of all workers on project 1019.

SELECT empLastname, empFirstName, deptName
FROM Worker
WHERE empID IN
	(SELECT empID
	FROM Assign
	WHERE projNo = '1019');

-- Get an alphabetical list of names and corresponding ratings of all workers on any project
-- that is managed by Michael Burns.

SELECT DISTINCT empLastName, empFirstName, rating
FROM Worker, Assign
WHERE Worker.empID = Assign.empID AND rating IS NOT NULL AND projNo IN
	(SELECT projNo
	FROM Project
	WHERE projMgrID =
		(SELECT empID
		FROM Worker
		WHERE empFirstName = 'Michael' AND empLastname = 'BURNS'
		)
	)
ORDER BY empLastname;

-- Create a view that has the project number and name of each project
-- along with the IDs and names of all workers assigned to it.

DROP VIEW ProjInfo;

CREATE VIEW ProjInfo AS
	SELECT P.projNo, P.projName, A.empID
	FROM Project P, Assign A
	WHERE P.projNo = A.projNo;

-- Using the view created in the question above find the project number and project
-- name of all projects to which employee 110 is assigned.

SELECT projNo, projName
FROM ProjInfo
WHERE empID = '110';

--Add a new worker named Jack Smith with ID of 1999 to the Research department.

INSERT 
INTO Worker(empFirstName, empLastname,empID, deptName)
VALUES ('John', 'Smith', 1999, 'Research');

-- Change the hours that employee 110 is assigned to project 1019, from 20 to 10.

UPDATE Assign
SET hoursAssigned = 10
WHERE projNo = 1019 AND empID = 110;

-- For all projects starting after May 1, 2014, find the project number and the 
-- IDs and names of all workers assigned to them.

SELECT A.projNo, A.empID, W.empFirstName, W.empLastName
FROM Assign A, Worker W
WHERE A.empID = W.empID AND A.projNo IN
	(SELECT projNo 
	FROM Project
	WHERE startDate > '2014-05-01');

-- For each project, list the project number and how many workers are assigned to it.

SELECT projNo, COUNT(projno) AS Employee_Total
FROM Assign
GROUP BY projNo;

-- Find the employee names and department manager names of all workers who are not assigned to any project.

SELECT empLastname, empFirstName
FROM Worker
WHERE empID NOT IN
	(SELECT empID
	FROM Assign);

-- Find the details of any project with the word “urn” anywhere in its name.

SELECT *
FROM Project
WHERE projName LIKE '%urn%';

-- Get a list of project numbers and names and starting dates of all projects that have the same starting date.

SELECT A.projNo, A.projName, A.startDate
FROM Project A , Project B
WHERE A.startDate = B.startDate AND A.projNo <> B.projNo;

-- Add a field called status to the Project table. Sample values for this field are active, completed, 
-- planned, and cancelled. Then write the command to undo this change.


ALTER TABLE Project
ADD status varchar(10);

SELECT * 
FROM Project;

ALTER TABLE Project
DROP COLUMN status;

-- Get the employee ID and project number of all employees who have no ratings on that project.

SELECT empID, projNo, rating
FROM Assign
WHERE rating IS NULL;

-- Assuming that salary now contains annual salary, find each worker’s ID, name, and monthly salary.

SELECT empID,empLastname,empFirstName, salary/12 monthly_salary
FROM Worker;

-- Add a field called numEmployeesAssigned to the Project table. Use the UPDATE command to insert 
-- values into the field to correspond to the current information in the Assign table. Then write a 
-- trigger that will update the field correctly whenever an assignment is made, dropped, or updated. 
-- Write the command to make these changes permanent.

ALTER TABLE Project
ADD numEmployeesAssigned int;

UPDATE Project
SET numEmployeesAssigned = holder.Employee_Total
FROM (SELECT Assign.projNo, COUNT(Assign.projNo) AS Employee_Total
	FROM Assign
	GROUP BY projNo) AS holder
WHERE project.projno = holder.projNo;

CREATE OR ALTER TRIGGER NUM_EMPLOYEE_UPDATE
ON Assign
AFTER INSERT,UPDATE, DELETE
AS BEGIN
	UPDATE Project
	SET numEmployeesAssigned = holder.Employee_Total
	FROM (SELECT Assign.projNo, COUNT(Assign.projNo) AS Employee_Total
		FROM Assign
		GROUP BY projNo) AS holder
	WHERE project.projno = holder.projNo
END

COMMIT;
