CREATE DATABASE TELECOM_TEAM_126


GO
CREATE PROC createAllTables
AS
Begin
	CREATE TABLE Customer_profile(
		nationalID INT PRIMARY KEY IDENTITY,
		first_name varchar(50),
		last_name varchar(50),
		email varchar(50),
		address varchchar(50),
		date_of_birth date
	);

	CREATE TABLE Customer_Account (
		mobileNo char(11) primary key ,
		pass varchar (50),
		balance decimal(10, 1),
		account_type varchar(50),
		start_date date,
		status varchar(50),
		point int,
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

	CREATE TABLE Process_Payment(
		paymentID int foreign key references Payment(paymentID),
		planID int foreign key references Service_Plan(planID),
		remaining_balance as (
			CASE
				WHEN Payment(amount) < Service_Plan(price)
				THEN Service_Plan(price) - Payment(amount)
				ELSE 0
			END
		),
		additional_amounts as (
			CASE
				WHEN Payment(amount) > Service_Plan(price)
				THEN Payment(amount) - Service_Plan(price)
				ELSE 0
			END
		)

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
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID),
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

	CREATE TABLE Cashback (															--->
		CashbackID INT IDENTITY,
		benefitID INT FOREIGN KEY REFERENCES Benefits(benefitID),
		walletID INT FOREIGN KEY REFERENCES Wallet(walletID),
		amount INT,
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

	CREATE TABLE PhysicalShop (
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

--------------------------------2.1 C
GO
CREATE PROC dropAllTables
AS
BEGIN
    -- Drop tables in reverse dependency order without any checks
    DROP TABLE Technical_Support_Ticket;
    DROP TABLE Voucher;
    DROP TABLE E_shop;
    DROP TABLE Physical_Shop;
    DROP TABLE Shop;
    DROP TABLE Plan_Provides_Benefits;
    DROP TABLE Cashback;
    DROP TABLE Exclusive_Offer;
    DROP TABLE Points_Group;
    DROP TABLE Benefits;
    DROP TABLE Transfer_money;
    DROP TABLE Wallet;
    DROP TABLE Process_Payment;
    DROP TABLE Payment;
    DROP TABLE Plan_Usage;
    DROP TABLE Subscription;
    DROP TABLE Service_Plan;
    DROP TABLE Customer_Account;
    DROP TABLE Customer_profile;
END;

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
	SELECT pay.* , acc.*
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
	WHERE sub.planID = @planID AND sub.subscibtion_date = @date
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
	WHERE mobileNo = @mobileNo AND start_date >= @from_date
	GROUP BY planID
);

--2.3 d																				------>INCOMPLETE
GO 
CREATE PROC Benefits_Account
@mobileNo char(11) , @planID int
AS
BEGIN
	DELETE FROM Benefits bnft
	JOIN Plan_Provides_Benefits ppb ON bnft.benefitID = ppb.benefitID


--2.3 e
GO
CREATE FUNCTION Account_SMS_Offers (@mobileNo char(11))
RETURNS TABLE
AS
RETURN(
	SELECT exoff.offerID, exoff.benefitID, exoff.SMS_offered
	FROM Exclusive_Offer exoff
	WHERE SMS_offered is not null
);

--2.3 f															      ---> Wallet considered transaction?
GO
CREATE PROC Account_Payment_Points
@mobileNo char(11) , @transactionsNo INT OUTPUT, @totalPoints INT OUTPUT
AS
	SELECT @transactionsNo = COUNT(*), @totalPoints = SUM(pg.pointsamount)
	FROM Payment pay
	JOIN Points_Group pg ON pay.PaymentID = pg.PaymentID
	WHERE pay.mobileNo = @mobileNo AND pay.status = 'successful' and year(pay.date_of_payment) = year(GETDATE()) - 1
	
--2.3 g																	---> INCOMPLETE
--GO
--CREATE FUNCTION Wallet_Cashback_Amount (@walletID int, @planId int)
--RETURNS int
--AS 
--BEGIN
--	DECLARE @cashback_amount int
--;


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

--2.3 j																	---> INCOMPLETE AAAAA33333333333333333





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
	SELECT planID, PlnUsg.data_consumption , PlnUsg.minutes_used , PlnUsg.SMS_sent
	FROM Plan_Usage PlnUsg
	JOIN Subscription sub ON PlnUsg.planID = sub.planID
	WHERE sub.mobileNo = @mobileNo AND sub.status = 'active' AND YEAR(sub.subscription_date) = YEAR(GETDATE()) AND MONTH(sub.subscription_date) = MONTH(GETDATE())
)

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
	JOIN Customer_Account acc ON tst.mobileNo = acc.mobileNo
	WHERE acc.nationalID = @natioanlID AND status != 'Resolved'


--2.4 g
GO
CREATE PROC Account_Highest_Voucher
@mobileNo char(11) , @voucherID int output
AS
	SELECT @voucherID = voucherID
	FROM Voucher
	WHERE mobileNo = @mobileNo
	HAVING value = MAX(value)
		
--2.4 h																				----> INCOMPLETE AAAAA333333
--GO
--CREATE FUNCTION Remaining_plan_amount (@mobileNo char(11) , @plan_name varchar(50))
--RETURNS 
--AS
--BEGIN



--2.4 i																				-----> INCOMPLETE ;kwjeriohwoierpo[


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
	subscription_date >= GETADD(MONTH, -5 , GETDATE())
)


	