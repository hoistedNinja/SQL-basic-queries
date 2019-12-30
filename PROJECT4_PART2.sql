

--1. view hotels,hotel rooms and those staying in the rooms,sorted by hotel and room and occupant
SELECT H.HOTEL_NAME,R.ROOM_ID,V.VOL_NAME as Occupant FROM HOTEL H 
JOIN ROOM R ON H.HOTEL_CODE=R.HOTEL_CODE
JOIN VOLUNTEER V ON V.ROOM_CODE=R.ROOM_ID
ORDER BY
H.HOTEL_NAME,R.ROOM_ID,V.VOL_NAME


--2 count unique individual per hotel room
SELECT R.ROOM_ID,COUNT(V.VOL_ID) AS 'INDIVDUAL PER ROOM' FROM HOTEL H 
JOIN ROOM R ON H.HOTEL_CODE=R.HOTEL_CODE
JOIN VOLUNTEER V ON V.ROOM_CODE=R.ROOM_ID

GROUP BY ROOM_ID


--3 COUNT UNIQUE INDIVIDUAL PER HOTEL
SELECT H.HOTEL_NAME,COUNT(V.VOL_ID) AS 'INDIVDUAL PER HOTEL' FROM HOTEL H 
JOIN ROOM R ON H.HOTEL_CODE=R.HOTEL_CODE
JOIN VOLUNTEER V ON V.ROOM_CODE=R.ROOM_ID

GROUP BY HOTEL_NAME

--4 VIEW VOLUNTEER AND EXHIBITS THEY ARE ASSOCIATED WITH
SELECT VOL_ID,VOL_NAME,VOL_PH_NUMBER,EXHIBIT_ID FROM VOLUNTEER

--5 VOLUNTEER HOURS ROLL UP BY EXHIBIT AND AREA
SELECT V.EXHIBIT_ID,V.AREA_CODE,sum(time_spent) AS 'TOTAL HOURS' FROM HOURS H 
JOIN VOLUNTEER V ON H.VOL_ID=V.VOL_ID 
GROUP BY V.EXHIBIT_ID ,AREA_CODE

--6 VIEW COUNT OF VOLUNTEER PER EXHIBIT AND AREA
SELECT exhibit_id,area_code,COUNT(DISTINCT vol_id) AS 'total number of volunteer' FROM volunteer 
GROUP BY EXHIBIT_ID,AREA_CODE

--7 VIEW EACH AREA AND PRESIDENT,VICE-PRESIDENT AND SECRETARY
SELECT v.area_code,v.vol_name AS NAME,v.VOL_TYPE AS POSITION FROM VOLUNTEER v JOIN PRESIDENT p ON v.AREA_CODE=p.AREA_CODE

JOIN VICE_PRESIDENT vp on vp.AREA_CODE=v.AREA_CODE

JOIN SECRETARY s on s.AREA_CODE=v.AREA_CODE

ORDER BY AREA_CODE

--8 VIEW A ROLL UP OF TOTAL MONEY DONATED AND TOTAL DONATED BY AREA
SELECT  area_code,SUM(AMOUNT_DONATED) AS 'Total Amount Donated' FROM donation  
GROUP BY area_code


--9 VIEW TOTAL OF DONATION BY DONOR
SELECT DISTINCT d.donor_id,d.DONOR_NAME ,sum(do.amount_donated) AS 'Total Amount Donated' FROM donor d 
JOIN DONATION do on d.DONOR_ID=do.DONOR_ID 
GROUP BY
d.DONOR_ID,d.DONOR_NAME


--10 VIEW DETAILS OF DONATIONS BY DONOR

SELECT 
D.DONOR_ID,
D.RECIEPT_NUM,
D.AMOUNT_DONATED,
D.CAMP_TITLE,
D.RECEIPT_DATE,
DO.DONOR_NAME,
DO.DONOR_ADD,
DO.DONOR_PH
FROM DONATION D JOIN DONOR DO ON D.DONOR_ID=DO.DONOR_ID
ORDER BY
DONOR_ID

-- 11 VIEW THE BUDGET BY AREA AND PRESIDENT
SELECT Y.AREA_CODE, Y.PRESIDENT_ID,V.VOL_NAME AS 'PRESIDENT NAME',Y.BUD_REQUESTED 
FROM YEARLY_BUDGET Y 
JOIN VOLUNTEER V ON Y.PRESIDENT_ID=V.VOL_ID

--12 VIEW DONATION CHRONOLOGICALLY(OLDER ONE FIRST) BY AREA
SELECT AREA_CODE,AMOUNT_DONATED,RECEIPT_DATE FROM DONATION
ORDER BY RECEIPT_DATE


------CREATE VIEW---------------

---View 1 – see luxury rooms details in all the hotel connection of organization

CREATE VIEW viewFindLuxuryRoom AS
( SELECT h.HOTEL_NAME,r.ROOM_ID,r.ROOM_FLOOR,r.ROOM_TYPE from ROOM r 
JOIN  HOTEL h on r.HOTEL_CODE=h.HOTEL_CODE
WHERE ROOM_TYPE='LUXURY')

SELECT * FROM viewFindLuxuryRoom -- CHECKING IF VIEW WORKS


--VIEW 2. VIEW THAT GIVES EXHIBITS INFO
CREATE VIEW vwExhibitInfo AS
(SELECT E.EXHIBIT_ID,E.EXHIBIT_NAME AS 'EXHIBIT SUBJECT',A.AREA_NAME FROM EXHIBIT E JOIN AREA A ON A.AREA_CODE=E.AREA_CODE)

SELECT * FROM vwExhibitInfo --CHECKING IF VIEW WORKS




--View 3.  gives total amount collected by each campaign title
CREATE VIEW vwSeeTotalByCampaign AS
(SELECT camp_title,sum(amount_donated) AS 'Total amount Recieved' FROM DONATION GROUP BY CAMP_TITLE)



select * from vwSeeTotalByCampaign ---CHECKING IF VIEW WORKS


--View 4. gives info about total rooms,hotel option and room options available in organization
CREATE VIEW  vwLodgingInfo AS 

(SELECT count(room_id) AS 'Total Rooms',count(distinct hotel_code) as 'Total Hotels',count(distinct room_type) AS 'Room Variety' FROM ROOM)

select * from vwLodgingInfo --CHECKING IF VIEW WORKS



--view 5  gives donation statistics
 CREATE VIEW  vwDonationStat AS 
 (SELECT max(amount_donated) AS 'Highest Donation',min(amount_donated) AS 'lowest Donation',ROUND(avg(amount_donated),2) AS 'Average Donation' FROM DONATION)

select * from vwDonationStat --CHECKING IF VIEW WORKS



----- STORED PROCEDURE NOW ON -----
--------------------------------------
--------------------------------------





--1.procedure helps user see details of particular volunteer using vol_id
CREATE PROCEDURE prc_Volunteer_Detail @v_id nvarchar(30)
AS
SELECT * FROM volunteer WHERE VOL_ID = @v_id

exec prc_Volunteer_Detail @v_id=376272 --  CHECKING IF PROCEDURE WORKS



--2. helps user see the lifetime donation sum made so far by particular donor using donor id
CREATE PROCEDURE prc_seeTotalAmountDonatedSoFar @d_id int
AS
SELECT D.DONOR_ID,D.DONOR_NAME,SUM(DO.AMOUNT_DONATED)AS 'TOTAL AMOUNT DONATED SO FAR'
FROM DONOR D JOIN DONATION DO ON D.DONOR_ID=DO.DONOR_ID
GROUP BY D.DONOR_ID,D.DONOR_NAME
HAVING D.DONOR_ID =@d_id

exec prc_seeTotalAmountDonatedSoFar @d_id=106  --  CHECKING IF PROCEDURE WORKS


--3. HELPS FIND HOTELS IN YOUR AREA SEARCH BY CITY OR STATE OR ACTUAL ADDRESS
CREATE PROCEDURE prc_FIND_HOTEL_IN_AREA @H_LOCATION nvarchar(30)
AS
SELECT * FROM HOTEL WHERE HOTEL_ADDRESS LIKE'%' + @H_LOCATION + '%'

exec prc_FIND_HOTEL_IN_AREA @H_LOCATION='BOSTON'  --  CHECKING IF PROCEDURE WORKS


-- 4.  Assigns room to volunteer if not assigned at registration and update the room if somebody wants to ,given vacant room available or anybody want to switch

CREATE PROCEDURE prc_assign_rooms @VOL_ID INT,@R_CODE INT
AS
UPDATE VOLUNTEER
SET ROOM_CODE=@R_CODE
WHERE VOL_ID=@VOL_ID

exec prc_assign_rooms @VOL_ID=376272,@R_CODE=101 -- ASSIGNS ROOM 101 TO VOLUNTEER WITH ID 376272
SELECT * FROM VOLUNTEER -- CHECKING IF UPDATES MADE



--5.  DISPLAYS THE INFORMATION OF ADMIN AND HIS CONTACT ADD
create procedure prc_display_Admin_info


as
print ' *************************************************************************************************    '
print ' Hi every body, This is Wade Kinsella. I was born in BlueBell Alabama.'
print '	I graduated from University of Alabama getting my first Phd in Data Science and cyberSecurity'
print ' Feel free to send me email asking any question you wanna ask . I will definately reply them all at wade.Kinsella@alstate.edu.'
print '**********************************************************************************************************'


exec prc_display_Admin_info -- DISPLAYS INFO OF ADMIN



-- END OF THE SCRIPT. MERRY CHRISTMAS PROFESSOR :)
