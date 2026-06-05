# 📚 Student Tracker — MySQL Database Project

A complete MySQL database project tracking student 
attendance, marks and academic performance for 35 
students across 4 subjects.

## Database Structure
- Students — 35 student records
- Subjects — Maths, Science, English, Computer
- Attendance — Auto-generated via stored procedure
- Marks — Cross-join populated across all subjects
- Report Card — Consolidated view with remarks

## Key Features
- Stored procedure auto-generates 3 months attendance
- View calculates real-time attendance percentage
- Automated remarks — Good Progress, Needs Academic 
  Guidance, Needs Attendance Improvement

## Business Objectives Solved
1. Top 5 students by attendance percentage
2. Subject-wise average marks ranking
3. Top 5 scoring students overall
4. Correlation between attendance and performance
5. At-risk students identification (avg marks below 60)
6. Students scoring above 90 in any subject
7. Subject difficulty ranking by fail percentage
8. Best subject for each student
9. Weakest subject for each student
10. Students with biggest subject score gaps
11. Students needing academic guidance

## Tools Used
- MySQL — Tables, Views, Stored Procedures, 
  CTEs, JOINs, UNION ALL, CASE statements

## Author
Arshad Seliya — Data Analyst
LinkedIn: linkedin.com/in/arshad-seliyaa49706397
GitHub: github.com/arshadseliya07
