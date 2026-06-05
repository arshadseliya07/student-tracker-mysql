CREATE DATABASE student_tracker;
USE student_tracker;
show tables;
select * from attendance;
select * from students;
select * from marks;
select * from report_card;
select * from subjects;
-- Student Table --
CREATE TABLE students (
student_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
gender ENUM('M','F'),
class VARCHAR(20));


INSERT INTO students (name, gender, class) VALUES
('Arjun Kumar','M','10A'),
('Riya Sharma','F','10A'),
('Kabir Singh','M','10A'),
('Sana Khan','F','10A'),
('Rahul Mehta','M','10A'),
('Neha Patel','F','10A'),
('Imran Shaikh','M','10A'),
('Zara Ansari','F','10A'),
('Vijay Rao','M','10A'),
('Aisha Noor','F','10A'),
('Karan Desai','M','10A'),
('Pooja Nair','F','10A'),
('Rohan Joshi','M','10A'),
('Meera Iyer','F','10A'),
('Aditya Verma','M','10A'),
('Tara Mohan','F','10A'),
('Yash Malhotra','M','10A'),
('Simran Chawla','F','10A'),
('Mohit Suri','M','10A'),
('Lavanya Reddy','F','10A'),
('Harsh Kapoor','M','10A'),
('Ananya Sen','F','10A'),
('Farhan Ali','M','10A'),
('Kritika Jain','F','10A'),
('Dev Singh','M','10A'),
('Sneha Pandey','F','10A'),
('Aman Gupta','M','10A'),
('Ishita Roy','F','10A'),
('Nikhil Rana','M','10A'),
('Priya Das','F','10A'),
('Shubham Yadav','M','10A'),
('Khushi Thakur','F','10A'),
('Tanishq Bansal','M','10A'),
('Divya Pillai','F','10A'),
('Arnav Kulkarni','M','10A');

select * from students;

-- Subject Table--
CREATE TABLE subjects (
subject_id INT AUTO_INCREMENT PRIMARY KEY,
subject_name VARCHAR(100) NOT NULL);


INSERT INTO subjects (subject_name) VALUES
('Maths'),
('Science'),
('English'),
('computer');
select * from report_card;
select * from subjects;

--- Attendance table---





CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    student_name VARCHAR(100),
    attend_date DATE,
    status ENUM('P','A'),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    UNIQUE (student_id, attend_date));


DELIMITER $$
CREATE PROCEDURE generate_attendance_2024()
BEGIN
DECLARE d DATE;
DECLARE last DATE;
SET d = '2024-01-01';
SET last = '2024-03-31';
WHILE d <= last DO
INSERT IGNORE INTO attendance (student_id, student_name, attend_date, status)
SELECT s.student_id, s.name, d, 
CASE 
WHEN RAND() >= 0.20 THEN 'P' ELSE 'A' 
END
FROM students s;
SET d = DATE_ADD(d, INTERVAL 1 DAY);
END WHILE;
END $$
DELIMITER ;

CALL generate_attendance_2024();

CREATE VIEW v_attendance_percentage AS
SELECT student_id, student_name, SUM(status = 'P') AS present_days, SUM(status = 'A') AS absent_days,
COUNT(*) AS total_days,
ROUND(SUM(status = 'P') / COUNT(*) * 100, 2) AS attendance_percentage
FROM attendance
GROUP BY student_id, student_name;

SELECT * FROM v_attendance_percentage;

-- marks table--
CREATE TABLE marks (
mark_id INT AUTO_INCREMENT PRIMARY KEY,
student_id INT,
subject_id INT,
marks_obtained INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));

INSERT INTO marks (student_id, subject_id, marks_obtained)
SELECT student_id, subject_id, FLOOR(50 + RAND()*50)
FROM students CROSS JOIN subjects;

--- report_card table---

CREATE TABLE report_card (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    student_name VARCHAR(100),
    maths_marks INT,
    science_marks INT,
    english_marks INT,
    computer_marks INT,
    attendance_percentage DECIMAL(5,2),
    remarks VARCHAR(255),
	FOREIGN KEY (student_id) REFERENCES students(student_id));



INSERT INTO report_card(student_id,student_name,maths_marks,science_marks,english_marks,computer_marks,attendance_percentage,remarks)
SELECT s.student_id, s.name,
(SELECT marks_obtained FROM marks WHERE student_id = s.student_id AND subject_id = 1 ORDER BY mark_id DESC LIMIT 1) AS maths_marks,
(SELECT marks_obtained FROM marks WHERE student_id = s.student_id AND subject_id = 2 ORDER BY mark_id DESC LIMIT 1) AS science_marks,
(SELECT marks_obtained FROM marks WHERE student_id = s.student_id AND subject_id = 3 ORDER BY mark_id DESC LIMIT 1) AS english_marks,
(SELECT marks_obtained FROM marks WHERE student_id = s.student_id AND subject_id = 4 ORDER BY mark_id DESC LIMIT 1) AS computer_marks,
(SELECT ROUND(SUM(status='P') / COUNT(*) * 100, 2) FROM attendance WHERE attendance.student_id = s.student_id) AS attendance_percentage,
CASE 
WHEN ((SELECT AVG(marks_obtained) FROM marks WHERE marks.student_id = s.student_id) < 65) THEN 'Needs Academic Guidance'
WHEN ((SELECT ROUND(SUM(status='P')/COUNT(*)*100,2) FROM attendance WHERE attendance.student_id = s.student_id) < 65) THEN 'Needs Attendance Improvement'
ELSE 'Good Progress'
END AS remarks
FROM students s;
select * from report_card;

-- objectives---

--- 1) Top 5 attendance_percentage for 3 months(Jan Feb March)------

SELECT s.name,SUM(status = 'P') AS present_days,SUM(status = 'A') AS absent_days,COUNT(*) AS total_days,ROUND(SUM(status='P') / COUNT(*) * 100, 2) AS attendance_percentage
FROM attendance a join students s on a.student_id=s.student_id WHERE attend_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY s.name ORDER BY attendance_percentage desc limit 5;

-- 2) Subject-wise Average Marks--

SELECT s.subject_name,AVG(m.marks_obtained) AS avg_marks FROM marks m JOIN subjects s ON m.subject_id = s.subject_id
GROUP BY m.subject_id order by avg_marks desc;

-- 3) Top 5 Scoring Students (Across All Subjects)--

SELECT st.student_id,st.name,SUM(m.marks_obtained) AS total_score,COUNT(m.marks_obtained) AS total_exams,
ROUND((SUM(m.marks_obtained) / (COUNT(m.marks_obtained) * 100)) * 100, 2) AS percentage
FROM marks m JOIN students st ON m.student_id = st.student_id
GROUP BY m.student_id ORDER BY total_score DESC
LIMIT 5;


--- 4) Correlation Between Attendance and Performance---

WITH attendance_summary AS (SELECT s.student_id,s.name,ROUND(SUM(status='P') / COUNT(*) * 100, 2) AS attendance_percentage
FROM attendance a join students s on a.student_id=s.student_id WHERE attend_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY s.student_id,s.name),
marks_summary AS (SELECT s.student_id,s.name,AVG(marks_obtained) AS avg_marks FROM marks m join students s on m.student_id=s.student_id
GROUP BY s.student_id,s.name)
SELECT a.name,a.attendance_percentage, m.avg_marks fROM attendance_summary a JOIN marks_summary m ON a.student_id = m.student_id
ORDER BY m.avg_marks DESC limit 5;

-- 5) Identify At-Risk Students (Low Marks)---
  
WITH marks_summary AS (SELECT s.student_id,s.name,AVG(m.marks_obtained) AS avg_marks FROM marks m
JOIN students s ON m.student_id = s.student_id GROUP BY s.student_id, s.name), 

at_risk AS (SELECT ms.student_id,ms.name,ms.avg_marks FROM marks_summary ms WHERE ms.avg_marks < 60)

SELECT ar.student_id,ar.name,ar.avg_marks,sub.subject_name FROM at_risk ar
JOIN marks mk ON ar.student_id = mk.student_id
JOIN subjects sub ON mk.subject_id = sub.subject_id
ORDER BY ar.student_id, mk.subject_id desc; 




-- 6th) Find students who scored above 90 in at least one subject
select * from subjects;
select * from marks;
SELECT DISTINCT s.student_id, s.name, su.subject_name,m.marks_obtained
FROM students s
JOIN marks m ON s.student_id = m.student_id 
join subjects su on m.subject_id=su.subject_id
WHERE m.marks_obtained > 90
limit 5;

--- 7th) Subject Difficulty Ranking Using Fail Count ---------

SELECT subject_name, fail_count, pass_count,(fail_count / (fail_count + pass_count)) * 100 AS fail_percentage FROM 
(SELECT 'Maths' AS subject_name,SUM(maths_marks < 55) AS fail_count,SUM(maths_marks >= 55) AS pass_count FROM report_card
UNION ALL
SELECT 'Science',SUM(science_marks < 55),SUM(science_marks >= 55) FROM report_card
UNION ALL 
SELECT 'English', SUM(english_marks < 55), SUM(english_marks >= 55) FROM report_card
UNION ALL        
SELECT 'Computer',SUM(computer_marks < 55),SUM(computer_marks >= 55) FROM report_card) AS subject_fail_stats
ORDER BY fail_percentage DESC
limit 5 ; 

----  8th) Best Subject for Each Student----- 
SELECT student_id,student_name, GREATEST(maths_marks, science_marks, english_marks, computer_marks) AS highest_score, 
CASE 
WHEN maths_marks = GREATEST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Maths'
WHEN science_marks = GREATEST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Science'
WHEN english_marks = GREATEST(maths_marks, science_marks, english_marks, computer_marks) THEN 'English'
WHEN computer_marks = GREATEST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Computer'
END AS best_subject
FROM report_card
limit 5;

-- 9) Identify Weak Subjects for Each Student--

SELECT student_id, student_name, LEAST(maths_marks, science_marks, english_marks, computer_marks) AS lowest_score,
CASE 
WHEN maths_marks = LEAST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Maths'
WHEN science_marks = LEAST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Science'
WHEN english_marks = LEAST(maths_marks, science_marks, english_marks, computer_marks) THEN 'English'
WHEN computer_marks = LEAST(maths_marks, science_marks, english_marks, computer_marks) THEN 'Computer'
END AS weakest_subject
FROM report_card
limit 5;

---- 10) Find Students With Big Subject Gaps

SELECT student_id, student_name, maths_marks, science_marks, english_marks, computer_marks,
GREATEST(maths_marks, science_marks, english_marks, computer_marks) AS highest_score,
LEAST(maths_marks, science_marks, english_marks, computer_marks) AS lowest_score,
GREATEST(maths_marks, science_marks, english_marks, computer_marks)
-LEAST(maths_marks, science_marks, english_marks, computer_marks)
AS score_gap
FROM report_card
ORDER BY score_gap DESC limit 5;  
select * from marks;
select * from report_card;

--- 11)Needs Academic Guidance-----

select rc.student_name,rc.maths_marks,rc.science_marks,rc.english_marks,rc.computer_marks,avg(m.marks_obtained) as avg_marks,rc.remarks  
from report_card rc
join marks m on rc.student_id=m.student_id
where rc.remarks="Needs Academic Guidance"
group by rc.student_name,rc.maths_marks,rc.science_marks,rc.english_marks,rc.computer_marks, rc.remarks;


use student_tracker;
