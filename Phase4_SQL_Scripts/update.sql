-- Insert details for student NetID 1002269238
INSERT INTO DASC5306_Fall25_S001_T8_Student (netID, username, email, password, phoneNo, age, date_of_enrollment, cumulativeGPA, enrolled_dept, nationality, apt, street, zipcode, county) VALUES 
('1002269238', 'nxg9239', 'nxg9239@mavs.uta.edu', 'Pass9239', '+1-469-487-1582', 25, TO_DATE('01-13-2025', 'MM-DD-YYYY'), 3.63, 'Data Science', 'Indian', 'Apt 132', 'Pinewoods', '78013', 'Tarrant');


-- Insert details for student NetID 1002278339
INSERT INTO DASC5306_Fall25_S001_T8_Student (netID, username, email, password, phoneNo, age, date_of_enrollment, cumulativeGPA, enrolled_dept, nationality, apt, street, zipcode, county) VALUES 
('1002278339', 'dxn8339', 'dxn8339@mavs.uta.edu', 'Pass8339', '+1-669-486-1682', 25, TO_DATE('01-13-2025', 'MM-DD-YYYY'), 3.63, 'Data Science', 'Indian', 'Apt 452', 'Heather Way', '78013', 'Tarrant');

-- Add a new podcast with ID POD051 and description 'Explore UTA Campus'
INSERT INTO DASC5306_Fall25_S001_T8_Podcast (podcast_ID, name, date_created, description) VALUES
('POD051', 'UTA Podcase', TO_DATE('2023-03-14', 'YYYY-MM-DD'), 'Explore UTA Campus');

-- Add an episode under POD051 podcast with title 'AI in Everyday Apps'
-- Duration is 40 minutes, uploaded on Feb 20, 2025
INSERT INTO DASC5306_Fall25_S001_T8_Episode (episodeNumber,podcast_ID,format,title,sourceURL,upload_date_time,duration) VALUES 
(1, 'POD051', 'audio', 'AI in Everyday Apps', 'https://podcasts.techbytes/ep1', TO_TIMESTAMP('2025-02-20 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 40);


-- Add advertiser CloudNest located in Dallas, with rate_per_view = $5.00
INSERT INTO DASC5306_Fall25_S001_T8_Advertiser (advertiserID,name,hqCity,rate_per_view) VALUES 
('ADV051', 'CloudNest', 'info@cloudnest.io', 5.00);

-- Add a new advertisement record for CloudNest AI Services
-- Associated with advertiser ID ADV041 (possible data correction later)
INSERT INTO DASC5306_Fall25_S001_T8_Advertisement VALUES 
('AD051', 'ADV041', 'CloudNest AI Services', 35, 'https://www.cloudnest.io/ai'); 

-- 1. Update GPA of student 1002284921 to 3.92
UPDATE DASC5306_Fall25_S001_T8_Student
SET cumulativeGPA = 3.92
WHERE netID = '1002284921';

-- 2. Update description of podcast POD001 to include more AI topics
UPDATE DASC5306_Fall25_S001_T8_Podcast
SET description = 'Exploring the latest AI, large language model, cloud, and quantum trends of the future.'
WHERE podcast_ID = 'POD001';

-- 3. Update duration of episode 3 under podcast POD001 to 50 minutes
UPDATE DASC5306_Fall25_S001_T8_Episode
SET duration = 50
WHERE podcast_ID = 'POD001' AND episodeNumber = 3;

-- 4. Update advertiser ADV031 headquarters city to 'Dallas Fortworth'
UPDATE DASC5306_Fall25_S001_T8_Advertiser
SET hqcity = 'Dallas Fortworth'
WHERE advertiserID = 'ADV031';

-- 5. Update product type of advertisement AD002 to 'PowerBI Bootcamp'
UPDATE DASC5306_Fall25_S001_T8_Advertisement
SET product_type = 'PowerBI Bootcamp'
WHERE adID = 'AD002';

-- 1. Delete a specific ad display linking episode 1 of POD001 with ADV001 and AD001
DELETE FROM DASC5306_Fall25_S001_T8_DisplayedIn
WHERE episodeNumber = 1 AND podcast_ID = 'POD001' AND advertiserID = 'ADV001' AND adId = 'AD001';

-- 2. Delete category 'E-commerce' entry related to ADV032 and AD042
DELETE FROM DASC5306_Fall25_S001_T8_Category
WHERE advertiserID = 'ADV032' AND adId = 'AD042' AND category = 'E-commerce';

-- 3. Delete ad display for ADV001 with adId AD003
DELETE FROM DASC5306_Fall25_S001_T8_DisplayedIn
WHERE advertiserID = 'ADV001' AND adId = 'AD003';


-- 4. Delete advertisement record itself for ADV001 and AD003
DELETE FROM DASC5306_Fall25_S001_T8_Advertisement
WHERE advertiserID = 'ADV001' AND adId = 'AD003';



