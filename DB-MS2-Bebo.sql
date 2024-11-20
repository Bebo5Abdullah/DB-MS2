CREATE DATABASE TELECOM_TEAM_126
DROP DATABASE TELECOM_TEAM_126




GO
CREATE PROC createAllTables
AS
Begin
	CREATE TABLE Customer_profile(

		nationalID INT PRIMARY KEY ,

		first_name varchar(50),
		last_name varchar(50),
		email varchar(50),
		address varchar(50),
		date_of_birth date
	);

	CREATE TABLE Customer_Account (
		mobileNo char(11) primary key ,
		pass varchar (50),
		balance decimal(10, 1),
		account_type varchar(50),
		start_date date,
		status varchar(50),
		point int default 0,
		nationalID int foreign key references Customer_profile(nationalID)
	);


	Create Table Service_Plan(
		planID int primary key identity,
		SMS_offered int,
		minutes_offered int,
		data_offered int,
		name varchar(50),
		price int,
		description varchar(50)
	);

	CREATE TABLE Subscription(
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		planID int foreign key references Service_Plan(planID),
		subscription_date date,
		status varchar(50),
		primary key(mobileNo, planID)
	);
	
	CREATE TABLE Plan_Usage(
		usageID int primary key identity,
		start_date date,
		end_date date,
		data_consumption int,
		minutes_used int,
		SMS_sent int,
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		planID int foreign key references Service_Plan(planID)
	);

	CREATE TABLE Payment(
		paymentID int primary key identity,
		amount decimal (10,1),
		date_of_payment date,
		payment_method varchar(50),
		status varchar(50),
		mobileNo char(11) foreign key references Customer_Account(mobileNo)
	);

	CREATE TABLE Process_Payment(												--------> PAYMENT(AMOUNT) badeena
		paymentID int foreign key references Payment(paymentID),
		planID int foreign key references Service_Plan(planID),
		remaining_balance as dbo.calcRemainBalance(paymentID, planID),
		extra_amount as dbo.calcExtraAmount(paymentID, planID)
	);

	

	CREATE TABLE Wallet(
		walletID int primary key identity,
		current_balance decimal(10, 2),
		currency varchar(50),
		last_modified_date date,
		nationalID int foreign key references Customer_profile(nationalID),
		mobileNo char(11)             
	);

	CREATE TABLE Transfer_money(
	walletID1 INT FOREIGN KEY REFERENCES Wallet(walletID),
	walletID2 INT FOREIGN KEY REFERENCES Wallet(walletID),
	transfer_id INT IDENTITY,
	amount decimal(10,2),
	transfer_date date,
	PRIMARY KEY(walletID1,walletID2, transfer_id)
);

	CREATE TABLE Benefits(
		benefitID INT Primary Key Identity,
		description VARCHAR(50),
		validity_date date,
		status varchar(50),
		mobileNo char(11) foreign key references Customer_Account(mobileNo)
	);

	CREATE TABLE Points_Group (
		pointID INT IDENTITY,
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID) ON DELETE CASCADE,
		pointsAmount INT,
		PaymentID INT FOREIGN KEY REFERENCES Payment(PaymentID),
		PRIMARY KEY(pointID, benefitID)
	);

	CREATE TABLE Exclusive_Offer (
		offerID INT IDENTITY,
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID),
		internet_offered INT,
		SMS_offered INT,
		minutes_offered INT,
		PRIMARY KEY(offerID, benefitID)
	);

	CREATE TABLE Cashback (															
		CashbackID INT IDENTITY,
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID),
		walletID INT FOREIGN KEY REFERENCES Wallet(walletID),
		amount INT default 0,
		credit_date DATE,
		PRIMARY KEY(CashbackID,benefitID)
	);

	CREATE TABLE Plan_Provides_Benefits (
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID),
		planID INT FOREIGN KEY REFERENCES Service_Plan(planID),
		PRIMARY KEY (benefitID, planID)
	);

	CREATE TABLE Shop (
		shopID INT IDENTITY PRIMARY KEY,
		name varchar(50),
		category varchar(50)
	);

	CREATE TABLE Physical_Shop (
		shopID INT PRIMARY KEY FOREIGN KEY REFERENCES Shop(shopID),
		address varchar(50),
		working_hours varchar(50)
	);

	CREATE TABLE E_shop (
		shopID INT PRIMARY KEY FOREIGN KEY REFERENCES Shop(shopID),
		URL VARCHAR(50),
		rating INT,
	);

	CREATE TABLE Voucher (
		voucherID INT PRIMARY KEY IDENTITY,
		value INT,
		expiry_date DATE,
		points INT,
		mobileNo CHAR(11) FOREIGN KEY REFERENCES Customer_Account(mobileNo),
		shopID INT FOREIGN KEY REFERENCES Shop(shopID),
		redeem_date DATE
	);

	CREATE TABLE Technical_Support_Ticket (
		ticketID INT IDENTITY,
		mobileNo CHAR(11) FOREIGN KEY REFERENCES Customer_Account(mobileNo),
		Issue_description VARCHAR(50),
		priority_level INT,
		status VARCHAR(50),
		PRIMARY KEY(ticketID,mobileNo)
	);

	
END;


ALTER TABLE Process_Payment DROP COLUMN remaining_balance
ALTER TABLE Process_Payment DROP COLUMN extra_amount
drop function calcRemainBalance, calcExtraAmount
ALTER TABLE Process_Payment ADD remaining_balance AS dbo.calcRemainBalance(paymentID, planID)
ALTER TABLE Process_Payment ADD extra_amount AS dbo.calcExtraAmount(paymentID, planID)


go
CREATE FUNCTION calcRemainBalance(@payID int, @planID int) 
RETURNS decimal(10,1) 
AS BEGIN
		DECLARE @x as decimal(10,1) = (SELECT pay.amount FROM Payment pay where pay.paymentID = @payID)
		DECLARE @y as decimal(10,1) = (SELECT sp.price FROM Service_Plan sp where sp.planID = @planID)
		DECLARE @res  decimal(10,1) 
		IF (@x > @y) 
			set @res = @x - @y
		ELSE 
			set @res = 0
		RETURN @res
END


go
CREATE FUNCTION calcExtraAmount(@payID int, @planID int) 
RETURNS decimal(10,1) 
AS BEGIN
		DECLARE @x as decimal(10,1) = (SELECT pay.amount FROM Payment pay where pay.paymentID = @payID)
		DECLARE @y as decimal(10,1) = (SELECT sp.price FROM Service_Plan sp where sp.planID = @planID)
		DECLARE @res  decimal(10,1) 
		IF (@x < @y) 
			set @res = @y - @x
		ELSE 
			set @res = 0
		RETURN @res
END


--------------------------------2.1 C
GO
CREATE PROC dropAllTables
AS
BEGIN
    -- Drop tables in reverse dependency order without any checks
    DROP TABLE IF EXISTS Transfer_money;
    DROP TABLE IF EXISTS Cashback;
	DROP TABLE IF EXISTS Points_Group;
    DROP TABLE IF EXISTS Exclusive_Offer;
    DROP TABLE IF EXISTS Plan_Provides_Benefits;
    DROP TABLE IF EXISTS Benefits;
    DROP TABLE IF EXISTS Subscription;
    DROP TABLE IF EXISTS Plan_Usage;
    DROP TABLE IF EXISTS Process_Payment;
    DROP TABLE IF EXISTS Payment;
    DROP TABLE IF EXISTS Wallet;
    DROP TABLE IF EXISTS Voucher;
    DROP TABLE IF EXISTS Technical_Support_Ticket;
    DROP TABLE IF EXISTS Customer_Account;
    DROP TABLE IF EXISTS E_shop;
    DROP TABLE IF EXISTS Physical_Shop;
    DROP TABLE IF EXISTS Service_Plan;
    DROP TABLE IF EXISTS Shop;
    DROP TABLE IF EXISTS Customer_profile;
END;

EXEC dropAllTables
-----------------------------------2.1 C END

-------------------------------2.1 e
GO
CREATE PROC clearAllTables
AS
BEGIN

    DELETE FROM Technical_Support_Ticket;
    DELETE FROM Voucher;
    DELETE FROM E_shop;
    DELETE FROM Physical_Shop;
    DELETE FROM Shop;
    DELETE FROM Plan_Provides_Benefits;
    DELETE FROM Cashback;
    DELETE FROM Exclusive_Offer;
    DELETE FROM Points_Group;
    DELETE FROM Benefits;
    DELETE FROM Transfer_money;
    DELETE FROM Wallet;
    DELETE FROM Process_Payment;
    DELETE FROM Payment;
    DELETE FROM Plan_Usage;
    DELETE FROM Subscription;
    DELETE FROM Service_Plan;
    DELETE FROM Customer_Account;
    DELETE FROM Customer_profile;

END;
-------------------------------------- 2.1 e END

--2.2 a
GO
CREATE VIEW allCustomerAccounts
AS
	SELECT pr.*, acc.mobileNo
	FROM Customer_profile pr 
	JOIN Customer_Account acc ON pr.nationalID = acc.nationalID
	WHERE acc.status = 'active'

--2.2 b
GO
CREATE VIEW AllServicePlans
AS
	SELECT * 
	FROM Service_Plan

--2.2 c
GO
CREATE VIEW AllBenefits
AS
	SELECT *
	FROM Benefits
	WHERE status = 'active' 

--2.2 d  
GO
CREATE VIEW AccountPayments
AS 
	SELECT pay.paymentID, pay.amount, pay.date_of_payment , pay.payment_method, pay.status as payment_status , acc.*
	FROM Payment pay 
	JOIN Customer_Account acc ON pay.mobileNo = acc.mobileNo

--2.2 e												 
GO
CREATE VIEW allShops
AS
	SELECT *
	FROM Shop

--2.2 f
GO 
CREATE VIEW allResolvedTickets
AS
	SELECT *
	FROM Technical_Support_Ticket
	WHERE status = 'Resolved'

--2.2 g												 
GO 
CREATE VIEW CustomerWallet
AS
	SELECT w.* , pr.first_name, pr.last_name
	FROM Wallet w
	JOIN Customer_profile pr ON w.nationalID = pr.nationalID

--2.2 h													
GO
CREATE VIEW E_shopVouchers
AS
	SELECT e.* , v.voucherID , v.value
	FROM E_shop e
	JOIN Voucher v ON e.shopID = v.shopID

--2.2 i
GO
CREATE VIEW PhysicalStoreVouchers
AS
	SELECT phys.* , v.voucherID , v.value
	FROM Physical_Shop phys
	JOIN Voucher v ON phys.shopID = v.shopID
;

--2.2 j
GO
CREATE VIEW Num_of_cashback
AS
	SELECT walletID , Count(CashbackID) as cashbacks_per_wallet
	FROM Cashback
	GROUP BY walletID
;

-------------------------------------------------------------------------------------------------------------------


--2.3 a															
GO
CREATE PROC Account_Plan
AS
	SELECT acc.* , sp.*
	FROM Subscription sub
	JOIN Customer_Account acc ON sub.mobileNo = acc.mobileNo
	JOIN Service_Plan sp ON sub.planID = sp.planID
	ORDER BY mobileNo
;

--2.3 b
GO
CREATE FUNCTION Account_Plan_date (@date date , @planID int)
RETURNS TABLE
AS
RETURN(
	SELECT sub.mobileNo, sub.planID , sp.name

	FROM Subscription sub
	JOIN Service_Plan sp ON sub.planID = sp.planID
	WHERE sub.planID = @planID AND sub.subscription_date = @date
);

--2.3 c
GO
CREATE FUNCTION Account_Usage_Plan (@mobileNO char(11) , @from_date date)

RETURNS TABLE
AS
RETURN(
	SELECT planID ,
	       SUM(data_consumption) as total_data_consumption , SUM(minutes_used) as total_minutes_used, SUM(SMS_sent) as total_SMS_sent
	FROM Plan_Usage
	WHERE mobileNo = @mobileNo AND start_date <= @from_date AND end_date >= @from_date
	GROUP BY planID

);


--2.3 d													---> Can't do Deletetr						
GO 
CREATE PROC Benefits_Account
@mobileNo char(11) , @planID int
AS
BEGIN
	DELETE FROM Benefits
	WHERE mobileNO = @mobileNo AND
	benefitID IN (SELECT benefitID from Plan_Provides_Benefits where planID = @planID)
END

--2.3 e
GO
CREATE FUNCTION Account_SMS_Offers (@mobileNo char(11))				
RETURNS TABLE
AS
RETURN(
	SELECT exoff.offerID, exoff.benefitID, exoff.SMS_offered
	FROM Exclusive_Offer exoff
	JOIN Benefits b ON exoff.benefitID = b.benefitID
	WHERE SMS_offered is not null AND SMS_offered > 0 AND b.mobileNo=@mobileNo
);

--2.3 f															     
GO
CREATE PROC Account_Payment_Points
@mobileNo char(11) , @transactionsNo INT OUTPUT, @totalPoints INT OUTPUT
AS
	SELECT @transactionsNo = COUNT(*), @totalPoints = SUM(pg.pointsamount)
	FROM Payment pay
	JOIN Points_Group pg ON pay.PaymentID = pg.PaymentID
	WHERE pay.mobileNo = @mobileNo AND pay.status = 'successful' and year(pay.date_of_payment) = year(GETDATE()) - 1

	
--2.3 g																	
GO
CREATE FUNCTION Wallet_Cashback_Amount (@walletID int, @planId int)
RETURNS int
AS 
BEGIN
	DECLARE @cashback_amount as int =  (
	SELECT amount FROM Cashback
	WHERE walletID = @walletID AND 
	benefitID IN (SELECT benefitID FROM Plan_Provides_Benefits WHERE planID = @planId)
	)
	RETURN @cashback_amount
END;


--2.3 h
GO
CREATE FUNCTION Wallet_Transfer_Amount (@walletID int , @start_date date , @end_date date)
RETURNS decimal(10,2)
AS
BEGIN
	DECLARE @avg decimal (10, 2)
	
	SELECT @avg = AVG(amount)
	FROM Transfer_money
	WHERE walletID1 = @walletID AND transfer_date >= @start_date AND transfer_date <= @end_date

	RETURN @avg
END

--2.3 i
GO
CREATE FUNCTION Wallet_MobileNo (@mobileNo char(11))
RETURNS bit
AS
BEGIN
	DECLARE @out bit
	IF EXISTS (
		SELECT walletID 
		FROM Wallet
		WHERE mobileNo = @mobileNo)

		SET @out = 1
	ELSE
		SET @out = 0

	RETURN @out
END

--2.3 j																	
GO
CREATE PROC Total_Points_Account @mobileNo char(11), @totalPoints int OUTPUT
AS
BEGIN
    SELECT @totalPoints = SUM(pg.pointsAmount)
    FROM Payment pay JOIN Points_Group pg on pay.paymentID = pg.PaymentID
    WHERE pay.mobileNo = @mobileNo
    UPDATE Customer_Account 
    SET point = @totalPoints
    WHERE mobileNo = @mobileNo
END



--GRANT ADMIN EXEC on 2.3
--GO
--GRANT EXEC ON PROCEDURE(Account_plan , Benefits_Account, Account_Payment_Points, Total_Points_Account) TO Admin
--GRANT EXEC ON FUNCTION(Account_plan_date , Account_Usage_Plan , Account_SMS_Offers , Wallet_Cashback_Amount, 
--						Wallet_Transfer_Amount, Wallet_MobileNo) TO Admin


--2.4 a
GO
CREATE FUNCTION AccountLoginValidation (@mobileNo char(11) , @password varchar(50))
RETURNS BIT
AS
BEGIN
	DECLARE @outbit bit 
	if EXISTS (
		SELECT mobileNo
		FROM Customer_Account
		WHERE mobileNo = @mobileNo AND pass = @password)

		SET @outbit = 1
	ELSE
		SET @outbit = 0

	RETURN @outbit
END;

--2.4 b
GO
CREATE FUNCTION Consumption (@plan_name varchar(50) , @start_date date , @end_date date)
RETURNS TABLE
AS 
RETURN(
	SELECT SUM(PlnUsg.data_consumption) as Total_data ,  SUM(PlnUsg.minutes_used) as Total_minutes , SUM(PlnUsg.SMS_sent) as Total_SMS 
	FROM Plan_Usage PlnUsg
	JOIN Service_Plan sp ON PlnUsg.planID = sp.planID
	WHERE sp.name = @plan_name AND PlnUsg.start_date >= @start_date AND PlnUsg.end_date <= @end_date
)

--2.4 c
GO
CREATE PROC Unsubscribed_Plans
@mobileNo char(11)
AS
	SELECT *
	FROM Service_Plan 
	WHERE planId NOT IN (SELECT planID FROM Subscription WHERE mobileNo = @mobileNo)

--2.4 d																			--->Should be SUM??? 
GO
CREATE FUNCTION Usage_Plan_CurrentMonth (@mobileNo char(11))
RETURNS TABLE
AS 
RETURN(
	SELECT PlnUsg.planID, PlnUsg.data_consumption , PlnUsg.minutes_used , PlnUsg.SMS_sent
	FROM Plan_Usage PlnUsg
	JOIN Subscription sub ON PlnUsg.planID = sub.planID
	WHERE sub.mobileNo = @mobileNo AND sub.status = 'active'
	AND Month(PlnUsg.start_date) <= Month(GETDATE()) AND YEAR(PlnUsg.start_date) <= YEAR(GETDATE())
	AND MONTH(PlnUsg.end_date) >= MONTH(GETDATE()) AND YEAR(PlnUsg.end_date) >= YEAR(GETDATE())
);


--2.4 e
GO
CREATE FUNCTION Cashback_Wallet_Customer (@nationalID int)
RETURNS TABLE
AS
RETURN(
	SELECT cb.*
	FROM Cashback cb
	JOIN Wallet w ON cb.walletID = w.walletID
	WHERE nationalID = @nationalID
);

--2.4 f
GO
CREATE PROC Ticket_Account_Customer
@nationalID int , @output int output
AS
	SELECT @output = COUNT(tst.ticketID) 
	FROM Technical_Support_Ticket tst
	RIGHT OUTER JOIN Customer_Account acc ON tst.mobileNo = acc.mobileNo
	WHERE acc.nationalID = @nationalID AND tst.status != 'Resolved'


--2.4 g
GO
CREATE PROC Account_Highest_Voucher
@mobileNo char(11) , @voucherID int output
AS
	SELECT @voucherID = voucherID
	FROM Voucher
	WHERE mobileNo = @mobileNo
	AND value = (SELECT MAX(Value)
				 FROM Voucher
				 WHERE mobileNo = @mobileNo)
		
--2.4 h																	-----> Which remaining balance if there is 2 payments for same plan			
GO
CREATE FUNCTION Remaining_plan_amount (@mobileNo char(11) , @plan_name varchar(50))
RETURNS decimal(10,1) 
AS
BEGIN
	DECLARE @planID as int  = (SELECT planID from Service_Plan WHERE name = @plan_name)
	DECLARE @rem decimal(10,1) = 
	(SELECT pp.remaining_balance
	FROM Process_Payment pp JOIN Payment pay 
	ON pp.paymentID = pay.paymentID 
	WHERE pay.mobileNO = @mobileNo AND pp.planID = @planID)
	RETURN @rem
END;



--2.4 i																	-----> Which extra amount if there is 2 payments for same plan				
GO
CREATE FUNCTION Extra_plan_amount (@mobileNo char(11) , @plan_name varchar(50))
RETURNS decimal(10,1) 
AS
BEGIN
	DECLARE @planID as int  = (SELECT planID from Service_Plan WHERE name = @plan_name)
	DECLARE @extra_amount decimal(10,1) = 
	(SELECT pp.extra_amount 
	FROM Process_Payment pp JOIN Payment pay 
	ON pp.paymentID = pay.paymentID 
	WHERE pay.mobileNO = @mobileNo AND pp.planID = @planID)
	RETURN @extra_amount
END;

--2.4 j
GO
CREATE PROC Top_Successful_Payments
@mobileNo char(11)
AS
	SELECT TOP 10 *
	FROM Payment
	WHERE mobileNo = @mobileNo AND status = 'successful'
	ORDER BY amount DESC


--2.4 k
GO 
CREATE FUNCTION Subscribed_plans_5_Months (@mobileNo char(11))
RETURNS TABLE
AS RETURN(
	SELECT sp.*
	FROM Service_Plan sp
	JOIN Subscription sub ON sp.planID = sub.planID
	WHERE sub.mobileNo = @mobileNo AND
	subscription_date >= DATEADD(MONTH, -5 , GETDATE())
)

--2.4 l
GO 
CREATE PROC Initiate_plan_payment
@mobileNo char(11) , @amount decimal(10,1), @payment_method varchar(50) , @planID int
AS
BEGIN
	INSERT INTO Payment VALUES (@amount , GETDATE() , @payment_method , 'successful' , @mobileNo)

	UPDATE Subscription
	SET status = 'active' , subscription_date = GETDATE()
	WHERE mobileNo = @mobileNo AND planID = @planID
END



--2.4 m
GO 
CREATE PROC  Payment_wallet_cashback  
@MobileNo char(11), @payment_id int,   int
AS 
BEGIN
	DECLARE @cashback as int = (Select amount FROM Payment WHERE paymentID = @payment_id AND mobileNO = @MobileNO ) * 0.10
	DECLARE @wallet_id as int = (Select walletID from Wallet WHERE mobileNo = @MobileNo)
	INSERT INTO Cashback VALUES(@benefit_id,@wallet_id, @cashback, GETDATE())
	UPDATE Wallet SET current_balance = current_balance + @cashback WHERE walletID = @wallet_id
END 
	

--2.4 n
GO
CREATE PROC Initiate_balance_payment
@mobileNo char(11) , @amount decimal(10 , 1) , @payment_method varchar(50)
AS
BEGIN
	INSERT INTO Payment VALUES (@amount , GETDATE() , @payment_method , 'successful' , @mobileNo)
	UPDATE Customer_Account
	SET balance = balance + @amount
	WHERE mobileNo = @mobileNo
END


--2.4 o
GO
CREATE PROC Redeem_voucher_points
@mobileNo char(11) , @voucherID int
AS
BEGIN
	IF ((SELECT expiry_date FROM Voucher WHERE voucherID = @voucherID) > GETDATE())
	BEGIN
		UPDATE Voucher 
		SET redeem_date = GETDATE()
		WHERE voucherID = @voucherID

		DECLARE @points as int = (SELECT points FROM Voucher WHERE voucherID = @voucherID)
		UPDATE Customer_Account
		SET point = point + @points
		WHERE mobileNo = @mobileNo
	END
	ELSE
		PRINT 'Voucher Expired'
END

----GRANT USER EXEC on 2.4
--GRANT EXEC ON FUNCTION(AccountLoginValidation, Consumption, Usage_Plan_CurrentMonth, Cashback_Wallet_Customer, 
--                        Remaining_plan_amount, Extra_plan_amount, Subscribed_plans_5_Months) TO customer

--GRANT EXEC ON PROC(Unsubscribed_Plans, Ticket_Account_Customer, Account_Highest_Voucher, Top_Successful_Payments, Initiate_plan_payment, 
--                    Payment_wallet_cashback, Initiate_balance_payment, Redeem_voucher_points ) TO customer




-- Insert data into Customer_Profile
INSERT INTO Customer_Profile (nationalID, first_name, last_name, email, address, date_of_birth)
VALUES 
(1, 'John', 'Doe', 'john.doe@example.com', '123 Elm Street', '1980-05-15'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '456 Oak Street', '1990-08-21'),
(3, 'Michael', 'Brown', 'michael.brown@example.com', '789 Pine Street', '1975-02-11');

SELECT* FROM Customer_Profile

-- Insert data into Customer_Account
INSERT INTO Customer_Account (mobileNo, pass, balance, account_type, start_date, status, point, nationalID)
VALUES 
-- Accounts for John Doe
('01234567890', 'password123', 100.0, 'Prepaid', '2023-01-01', 'active', 0, 1),
('02345678901', 'password456', 50.0, 'Post Paid', '2023-02-01', 'onhold', 20, 1),

-- Accounts for Jane Smith
('03456789012', 'password789', 200.0, 'Pay_as_you_go', '2023-03-01', 'active', 15, 2),
('04567890123', 'password012', 150.0, 'Prepaid', '2023-04-01', 'onhold', 5, 2),

-- Accounts for Michael Brown
('05678901234', 'password345', 75.0, 'Post Paid', '2023-05-01', 'active', 10, 3),
('06789012345', 'password678', 90.0, 'Pay_as_you_go', '2023-06-01', 'onhold', 25, 3);

SELECT* FROM Customer_Account

-- Insert data into Service_Plan
INSERT INTO Service_Plan (SMS_offered, minutes_offered, data_offered, name, price, description)
VALUES 
(100, 500, 5, 'Plan A', 30, 'Basic Plan'),
(200, 1000, 10, 'Plan B', 50, 'Standard Plan'),
(300, 1500, 15, 'Plan C', 70, 'Premium Plan');

SELECT*FROM Service_Plan

-- Insert data into Subscription
INSERT INTO Subscription (mobileNo, planID, subscription_date, status)
VALUES 
('01234567890', 1, '2023-01-15', 'active'),
('02345678901', 2, '2023-02-15', 'onhold'),
('03456789012', 3, '2023-03-15', 'active'),
('04567890123', 1, '2023-04-15', 'onhold'),
('05678901234', 2, '2023-05-15', 'active'),
('06789012345', 3, '2023-06-15', 'onhold');

SELECT* FROm Subscription


-- Insert data into Plan_Usage
INSERT INTO Plan_Usage (start_date, end_date, data_consumption, minutes_used, SMS_sent, mobileNo, planID)
VALUES 
('2023-01-01', '2023-01-31', 2, 100, 10, '01234567890', 1),
('2023-02-01', '2023-02-28', 4, 200, 20, '02345678901', 2),
('2023-03-01', '2023-03-31', 6, 300, 30, '03456789012', 3),
('2023-04-01', '2023-04-30', 8, 400, 40, '04567890123', 1),
('2023-05-01', '2023-05-31', 10, 500, 50, '05678901234', 2),
('2023-06-01', '2023-06-30', 12, 600, 60, '06789012345', 3);

SELECT * FROM Plan_Usage

-- Insert data into Payment
INSERT INTO Payment (amount, date_of_payment, payment_method, status, mobileNo)
VALUES 
(30.0, '2023-01-10', 'cash', 'successful', '01234567890'),
(50.0, '2023-02-10', 'credit', 'pending', '02345678901'),
(70.0, '2023-03-10', 'cash', 'rejected', '03456789012'),
(90.0, '2023-04-10', 'credit', 'successful', '04567890123'),
(110.0, '2023-05-10', 'cash', 'pending', '05678901234'),
(130.0, '2023-06-10', 'credit', 'successful', '06789012345');

SELECT* FROM Payment

-- Insert data into Process_Payment
INSERT INTO Process_Payment (paymentID, planID)
VALUES 
(1, 1),
(2, 2),
(3, 3);

SELECT* FROM Process_Payment


-- Insert data into Wallet
INSERT INTO Wallet (current_balance, currency, last_modified_date, nationalID, mobileNo)
VALUES 
(100.0, 'USD', '2023-01-05', 1, '01234567890'),
(200.0, 'USD', '2023-02-05', 2, '03456789012'),
(150.0, 'USD', '2023-03-05', 3, '05678901234');


SELECT* FROM Wallet
DELETE FROM Wallet

-- Insert data into Transfer_money
INSERT INTO Transfer_money (walletID1, walletID2, amount, transfer_date)
VALUES 
(1, 2, 50.0, '2023-01-20'),
(2, 3, 70.0, '2023-02-20'),
(1, 3, 100.0, '2023-03-20'),
(2, 1, 120.0, '2023-04-20'),
(3, 2, 80.0, '2023-05-20'),
(3, 1, 90.0, '2023-06-20');
SELECT* FROM Transfer_money


-- Insert data into Benefits
INSERT INTO Benefits (description, validity_date, status, mobileNo)
VALUES 
('10% Discount', '2023-12-31', 'active', '01234567890'),
('Free SMS', '2023-11-30', 'expired', '02345678901'),
('Double Data', '2023-10-31', 'active', '03456789012'),
('Extra Minutes', '2023-09-30', 'expired', '04567890123'),
('Cashback', '2023-08-31', 'active', '05678901234'),
('Special Plan', '2023-07-31', 'expired', '06789012345');

SELECT* FROM Benefits


-- Insert data into Points_Group
INSERT INTO Points_Group (benefitID, pointsAmount, PaymentID)
VALUES 
(1, 50, 1),
(2, 30, 2),
(3, 70, 3),
(4, 20, 4),
(5, 90, 5),
(6, 60, 6);

SELECT* FROM Points_Group


-- Insert data into Exclusive_Offer
INSERT INTO Exclusive_Offer (benefitID, internet_offered, SMS_offered, minutes_offered)
VALUES 
(1, 1, 10, 50),
(2, 2, 20, 100),
(3, 3, 30, 150),
(4, 4, 40, 200),
(5, 5, 50, 250),
(6, 6, 60, 300);

SELECT* FROM Exclusive_Offer
DELETE FROM Exclusive_Offer


-- Insert data into CashBack
INSERT INTO CashBack (benefitID, walletID, amount, credit_date)
VALUES 
(1, 1, 3.0, '2023-01-11'),
(3, 2, 7.0, '2023-02-11'),
(5, 3, 11.0, '2023-03-11');


SELECT* FROM CashBack
DELETE FROM CashBack
TRUNCATE TABLE Cashback


-- Insert data into Plan_Provides_Benefits
INSERT INTO Plan_Provides_Benefits (benefitID, planID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(5, 2),
(6, 3);

SELECT* FROM Plan_Provides_Benefits

-- Insert data into Shop
INSERT INTO Shop (name, category)
VALUES 
('Tech World', 'Electronics'),
('Fashion Hub', 'Clothing'),
('Gadget Store', 'Electronics'),
('Home Essentials', 'Furniture'),
('Books & More', 'Books'),
('Game Corner', 'Gaming');


SELECT* FROM Shop
DELETE FROM Shop


-- Insert data into Physical_Shop
INSERT INTO Physical_Shop (shopID, address, working_hours)
VALUES 
(1, 'Tech Lane 123', '9 AM - 9 PM'),
(2, 'Fashion Street 456', '10 AM - 8 PM'),
(3, 'Gadget Ave 789', '9 AM - 10 PM'),
(4, 'Home St 321', '8 AM - 6 PM'),
(5, 'Book Blvd 654', '9 AM - 7 PM'),
(6, 'Game Road 987', '10 AM - 9 PM');

SELECT* FROM Physical_Shop



-- Insert data into E_shop
INSERT INTO E_shop (shopID, URL, rating)
VALUES 
(1, 'https://www.techworld.com', 5),
(2, 'https://www.fashionhub.com', 4),
(3, 'https://www.gadgetstore.com', 3),
(4, 'https://www.homeessentials.com', 4),
(5, 'https://www.booksandmore.com', 5),
(6, 'https://www.gamecorner.com', 5);

SELECT* FROM E_shop


-- Insert data into Voucher
INSERT INTO Voucher (value, expiry_date, points, mobileNo, shopID, redeem_date)
VALUES 
(100, '2023-12-31', 20, NULL, 1, NULL),  -- Not redeemed
(50, '2023-11-30', 10, NULL, 2, NULL),   -- Not redeemed
(200, '2023-10-31', 30, '01234567890', 3, '2023-09-01'),
(150, '2023-09-30', 25, '03456789012', 4, '2023-08-01'),
(75, '2023-08-31', 15, '05678901234', 5, '2023-07-01'),
(125, '2023-07-31', 22, '04567890123', 6, '2023-06-01');


SELECT* FROM Voucher
DELETE FROM Voucher


-- Insert data into Technical_Support_Ticket
INSERT INTO Technical_Support_Ticket (mobileNo, Issue_description, priority_level, status)
VALUES 
('01234567890', 'Internet not working', 1, 'Open'),
('02345678901', 'Billing issue', 2, 'In Progress'),
('03456789012', 'Cannot make calls', 3, 'Resolved'),
('04567890123', 'Slow connection', 1, 'Open'),
('05678901234', 'Account locked', 2, 'In Progress'),
('06789012345', 'Plan activation failed', 3, 'Resolved');


SELECT* FROM Technical_Support_Ticket
DELETE FROM Technical_Support_Ticket




--test allCustomerAccounts view
SELECT* FROM Customer_Profile;
SELECT* FROM Customer_Account;
SELECT* FROM allCustomerAccounts;

--test allServicePlans view
SELECT* FROM Service_Plan;
SELECT* FROM allServicePlans;

--test allBenefits view
SELECT* FROM Benefits;
SELECT* FROM allBenefits;

--test AccountPayments view
SELECT* FROM Customer_Account;
SELECT* FROM Payment;
SELECT* FROM AccountPayments;

--test allShops view
SELECT* FROM Shop;
SELECT* FROM allShops;

--test allResolvedTickets view
SELECT* FROM Technical_Support_Ticket;
SELECT* FROM allResolvedTickets;

--test CustomerWallet view
SELECT* FROM Customer_Profile;
SELECT* FROM Wallet;
Select* FROM CustomerWallet;

--test E_shopVouchers view
SELECT* FROM E_shop;
SELECT * FROM Voucher;
SELECT* FROM E_shopVouchers;

--test PhysicalStoreVouchers view
SELECT* FROM Physical_Shop;
SELECT* FROM Voucher;
SELECT* FROM PhysicalStoreVouchers;

--test Num_of_cashback view
SELECT* FROM CashBack;
SELECT*FROM Wallet;
SELECT* FROM Num_of_cashback;

--test Account_Plan Procedure
SELECT* FROM Customer_Account;
SELECT* FROM Service_Plan;
SELECT* FROM Subscription;
EXEC Account_Plan;

--test Benefits_Account procedure
SELECT* FROM Benefits;
SELECT* FROM Plan_Provides_Benefits;
SELECT* FROM Subscription;
EXEC Benefits_Account @mobileNo = '01234567890',@planID = 1;

--test for Account_Plan_date
SELECT* FROM Customer_Account
SELECT* FROM Subscription
SELECT* FROM Service_Plan
SELECT* FROM Account_Plan_date('2023-01-15',1)

--test for Account_Usage_Plan
SELECT* FROM Customer_Account
SELECT* FROM Plan_Usage
SELECT* FROM Subscription
SELECT* FROM Account_Usage_Plan('01234567890','2023-01-01')

--test Benefits_Account procedure
SELECT* FROM Benefits;
SELECT* FROM Plan_Provides_Benefits;
SELECT* FROM Subscription;
EXEC Benefits_Account @mobileNo = '01234567890',@planID = 1;

--test for Account_SMS_Offers
SELECT* FROM Exclusive_Offer
SELECT* FROM Customer_Account
SELECT* FROM Benefits
SELECt* FROM Account_SMS_Offers('03456789012')

--test Account_Payment_Points procedure
SELECT * FROM Payment WHERE status = 'successful';
SELECT* FROM Points_Group;
DECLARE @TotalTransactions INT,
        @TotalPoints INT;
EXEC Account_Payment_Points  '04567890123',  @TotalTransactions OUTPUT,   @TotalPoints OUTPUT;
SELECT @TotalTransactions AS TotalNumberOfTransactions, @TotalPoints AS TotalAmountOfPoints;

--test Wallet_Cashback_Amount
SELECT* FROM CashBack
SELECT* FROM Plan_Provides_Benefits 
DECLARE @CashbackAmount DECIMAL(10, 2);
    SELECT @CashbackAmount = dbo.Wallet_Cashback_Amount(1, 1);
    SELECT @CashbackAmount AS CashbackAmount;

--test Wallet_Transfer_Amount
SELECT* FROM Transfer_money

DECLARE @AverageAmount DECIMAL(10, 2);
    SELECT @AverageAmount = dbo.Wallet_Transfer_Amount(2, '2023-01-01', '2023-05-01');
    SELECT @AverageAmount AS AverageTransactionAmount;

--test for Wallet_MobileNo
SELECT* FROM Wallet
SELECT* FROM Customer_Account
SELECT dbo.Wallet_MobileNo('01234567890'); --return 1
SELECT dbo.Wallet_MobileNo('05678901234'); --return 1
SELECT dbo.Wallet_MobileNo('07890123456'); --return 0
SELECT dbo.Wallet_MobileNo('08901234567'); --return 0

--test Total_Points_Account
SELECT* FROM Points_Group
SELECT* FROM Customer_Account

DECLARE @TotalPoints1 INT;
EXEC Total_Points_Account @MobileNo = '01234567890', @TotalPoints = @TotalPoints1 OUTPUT;
SELECT @TotalPoints1 AS TotalPoints;  -- returns 50

DECLARE @TotalPoints INT;
EXEC Total_Points_Account @MobileNo = '02345678901', @TotalPoints = @TotalPoints OUTPUT;
SELECT @TotalPoints AS TotalPoints2;  --return 30

--test for AccountLoginValidation
SELECT * FROM Customer_Account
SELECT dbo.AccountLoginValidation('01234567890' , 'password123')

--test for Consumption
SELECT * FROM Plan_Usage WHERE planID = 1
SELECT * FROM Service_Plan
SELECT * FROM dbo.Consumption('Plan A', '2023-01-01' , '2023-04-10')

--test for Unsubscribed_Plans
SELECT * FROM Service_Plan
SELECT * FROM Subscription WHERE mobileNo = '01234567890'
EXEC Unsubscribed_Plans '01234567890'

--test for Usage_Plan_CurrentMonth
SELECT * FROM Plan_Usage
SELECT * FROM Subscription WHERE mobileNo = '01234567890'
SELECT * FROM dbo.Usage_Plan_CurrentMonth('01234567890')

--test for Cashback_Wallet_Customer
SELECT * FROM Customer_Account
SELECT * FROM Wallet
SELECT * FROM Cashback
SELECT * FROM dbo.Cashback_Wallet_Customer(1)

--test for Ticket_Account_Customer
SELECT * FROM Customer_Account
SELECT * FROM Technical_Support_Ticket
DECLARE @tck int = 0
EXEC Ticket_Account_Customer 1 , @tck output
PRINT @tck

--test for Account_Highest_Voucher
SELECt * FROM Customer_Account
SELECT * FROM Voucher
DECLARE @vouch int
EXEC Account_Highest_Voucher '01234567890', @vouch output
PRINT @vouch

--test for Remaining_plan_amount
SELECT * FROM Service_Plan
SELECt * FROM Payment
SELECT * FROM Process_Payment
INSERT INTO Process_Payment VALUES (6,3) , (2,3)
SELECT dbo.Remaining_plan_amount('06789012345', 'Plan C')

--test for Extra_plan_amount
SELECT dbo.Extra_plan_amount('02345678901', 'Plan C')

--test for Top_Successful_Payments
SELECT * FROM Payment
INSERT INTO Payment VALUES(60, '2023-01-10' , 'cash' , 'successful' , '01234567890')

--test for Subscribed_plans_5_Months
SELECT * FROM Subscription
SELECT * FROM Service_Plan
INSERT INTO Subscription VALUES ('01234567890' , 2 , '2024-7-30' , 'active')
SELECT * FROM dbo.Subscribed_plans_5_Months('01234567890')

--test for Initiate_plan_payment
EXEC Initiate_plan_payment '02345678901' , 50.0 , 'cash' , 2
SELECT * FROM Payment
SELECT * FROM Service_Plan
SELECT * FROM Subscription

--test for Payment_wallet_cashback
--EXEC Payment_wallet_cashback 
SELECT * FROM Cashback
SELECT * FROM Payment
SELECT * FROM Benefits
SELECT * FROM Wallet


--test for Initiate_balance_payment
SELECT * FROM Payment
SELECt * FROM Customer_Account
EXEC Initiate_balance_payment '01234567890' , 110.0 , 'credit' 

--test for Redeem_voucher_points
INSERT INTO Voucher VALUES (100000 , DATEADD(YEAR, 1, GETDATE()) , 1000 , '01234567890' , 2 , Null)
EXEC Redeem_voucher_points '01234567890' , 7
SELECT * FROM Customer_Account
SELECT * FROM Voucher



