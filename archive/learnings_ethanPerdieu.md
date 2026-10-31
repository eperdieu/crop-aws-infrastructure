**Technical Challenges:**

One of the first technical challenges that I dealt with pertained to the filepaths being to long when downloading the dependencies. Windows has a default maximum path length of 260 characters, which this path was longer:

C:\ISA Local Code Base\f2024_s2025_indy_indianasoybeanalliance_farmconservationwebscraping\.venv\Lib\site-packages\pgadmin4\pgadmin\browser\server_groups\servers\databases\dbms_job_scheduler\dbms_programs\templates\dbms_programs\ppas\16_plus\enable_disable.sql

To fix this issue, I had to open my Registry Editor and navigate through the path HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem. I was then able to locate the LongPathsEnable section and set the value to 1 so I can have longer than 260 character paths.

Another bottleneck I faced was during the check for PostgreSQL. I noticed I had it installed yet the command psql --version was still showing command not found. To fix this I had go into my Environment Variables -> System Variables -> Path -> Edit. Here I was able to enter my PostgreSQL bin folder path so it can be recognized by VScode.

**Improvement Opportunities:**
One improvement that I noticed pertained the .env file. Currently it is set up using the DB_NAME of postgres while the script in the backend creates programs_db. Another improvement is changing the error codes of endpoints from Error - 500 too a more comprehensive error that users can understand. 

**Reflection Prompts:**
The most surprising thing I learned while working on the codebase was the integration of postgreSQL. I have never worked with databases in the past so it was interesting to see how postgres and super users worked. More specifically, the amount of control you have when creating databases. This consisted of creating the tables and enforcing the schema rules that were set in place. I was also surpised to see how the .env file tied everything together pertaining to the database. Something that I already knew that helped was being familiar with bash scripting. This allowed me to navigate and debug issues quicker than if I had no experience. This background of bash scripting allowed me to focus on newer concepts such as PostgreSQL and Node.js. 

An improvement idea that could be applied to the program would be the addition of a Recently Viewed Programs tab. This can improve usability and save time for farmers who forgot to favorite a given program. In the frontend, we would have to create a button named "Recently Viewed" in the farmers dashboard. This will then take them to a new stored programs page where it sorts the programs by recently viewed. In the backend we will need to either add to a pre-exisitng database or create a new one for the recently viewed programs. This would contain user IDs, program IDs and the timestamp of when they accessed the program. Their would also need to be new API endpoints one with the method GET to return the programs and another with the method POST to log the programs.