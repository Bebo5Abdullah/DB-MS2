CREATE DATABASE TELECOM_TEAM_126




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
		remaining_balance as dbo.calcRemainBalance(),
		extra_amount as dbo.calcExtraAmount()
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



go
CREATE FUNCTION calcRemainBalance() 
RETURNS decimal(10,1) 
AS BEGIN
		DECLARE @x as decimal(10,1) = (SELECT pay.amount FROM Payments pay, Process_Payments pp where pay.paymentID = pp.paymentID)
		DECLARE @y as decimal(10,1) = (SELECT pp.price FROM Service_Plan sp, Process_Payments pp where sp.planID = pp.planID)
		DECLARE @res  decimal(10,1) 
		IF (@x > @y) 
			set @res = @x - @y
		ELSE 
			set @res = 0
		RETURN @res
END


go
CREATE FUNCTION calcExtraAmount() 
RETURNS decimal(10,1) 
AS BEGIN
		DECLARE @x as decimal(10,1) = (SELECT pay.amount FROM Payments pay, Process_Payments pp where pay.paymentID = pp.paymentID)
		DECLARE @y as decimal(10,1) = (SELECT pp.price FROM Service_Plan sp, Process_Payments pp where sp.planID = pp.planID)
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



--2.3 d																			
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
	WHERE SMS_offered is not null AND SMS_offered > 0
);

--2.3 f															      ---> Wallet considered transaction? last year walla sana men delwa2ty
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
		
--2.4 h																	-----> Which remaining balance if there is 2 payments for same plan			
GO
CREATE FUNCTION Remaining_plan_amount (@mobileNo char(11) , @plan_name varchar(50))
RETURNS decimal(10,1) 
AS
BEGIN
	DECLARE @planID as int  = (SELECT planID from Service_Plan WHERE name = @plan_name)
	DECLARE @rem decimal(10,1) = 
	(SELECT SUM(pp.remaining_balance) 
	FROM Process_Payment pp JOIN Payment pay 
	ON pp.paymentID = pay.paymentID 
	WHERE pay.mobileNO = @mobileNo AND pp.planID = @planID)
	RETURN @rem
END;



--2.4 i																	-----> Which extra amount if there is 2 payments for same plan				
GO
CREATE FUNCTION Remaining_plan_amount (@mobileNo char(11) , @plan_name varchar(50))
RETURNS decimal(10,1) 
AS
BEGIN
	DECLARE @planID as int  = (SELECT planID from Service_Plan WHERE name = @plan_name)
	DECLARE @extra_amount decimal(10,1) = 
	(SELECT SUM(pp.extra_amount) 
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
	subscription_date >= GETADD(MONTH, -5 , GETDATE())
)

--2.4 l
GO 
CREATE PROC Initiate_plan_payment
@mobileNo char(11) , @amount decimal(10,1), @payment_method varchar(50) , @planID int
AS
BEGIN
	INSERT INTO Payment VALUES (@amount , GETDATE() , @payment_method , 'successful' , @mobileNo)

	UPDATE Subscription
	SET status = 'active' , subscirption_date = GETDATE()
	WHERE mobileNo = @mobileNo AND planID = @planID
END



--2.4 m
GO 
CREATE PROC  Payment_wallet_cashback  
@MobileNo char(11), @payment_id int, @benefit_id int
AS 
BEGIN
	DECLARE @cashback as int = (Select amount FROM Payment WHERE payment_id = @payment_id AND mobileNO = @MobileNO ) * 0.10
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


EXEC createAllTables


-- Insert into Customer_profile
INSERT INTO Customer_profile VALUES (1, 'John', 'Doe', 'john.doe@example.com', '123 Main St', '1990-01-01');
INSERT INTO Customer_profile VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', '456 Elm St', '1985-05-15');
INSERT INTO Customer_profile VALUES (3, 'Alice', 'Johnson', 'alice.johnson@example.com', '789 Oak St', '1992-09-20');
INSERT INTO Customer_profile VALUES (4, 'Bob', 'Brown', 'bob.brown@example.com', '101 Pine St', '1988-03-10');
INSERT INTO Customer_profile VALUES (5, 'Eve', 'Davis', 'eve.davis@example.com', '202 Maple St', '1995-12-25');

-- Insert into Customer_Account
INSERT INTO Customer_Account VALUES ('12345678901', 'password1', 100.0, 'Prepaid', '2023-01-01', 'Active', 50, 1);
INSERT INTO Customer_Account VALUES ('12345678902', 'password2', 200.0, 'Postpaid', '2023-02-01', 'Inactive', 100, 2);
INSERT INTO Customer_Account VALUES ('12345678903', 'password3', 300.0, 'Prepaid', '2023-03-01', 'Active', 150, 3);
INSERT INTO Customer_Account VALUES ('12345678904', 'password4', 400.0, 'Postpaid', '2023-04-01', 'Suspended', 200, 4);
INSERT INTO Customer_Account VALUES ('12345678905', 'password5', 500.0, 'Prepaid', '2023-05-01', 'Active', 250, 5);

-- Insert into Service_Plan
INSERT INTO Service_Plan VALUES (100, 500, 1000, 'Basic Plan', 10, 'Affordable basic plan');
INSERT INTO Service_Plan VALUES (200, 1000, 2000, 'Standard Plan', 20, 'Standard plan with good features');
INSERT INTO Service_Plan VALUES (300, 1500, 3000, 'Premium Plan', 30, 'Premium plan for heavy users');
INSERT INTO Service_Plan VALUES (400, 2000, 4000, 'Unlimited Plan', 40, 'Unlimited plan for unlimited usage');
INSERT INTO Service_Plan VALUES (500, 2500, 5000, 'Family Plan', 50, 'Family plan with shared benefits');

-- Insert into Subscription
INSERT INTO Subscription VALUES ('12345678901', 100, '2024-01-01', 'Active');
INSERT INTO Subscription VALUES ('12345678902', 200, '2024-02-01', 'Inactive');
INSERT INTO Subscription VALUES ('12345678903', 300, '2024-03-01', 'Active');
INSERT INTO Subscription VALUES ('12345678904', 400, '2024-04-01', 'Suspended');
INSERT INTO Subscription VALUES ('12345678905', 500, '2024-05-01', 'Active');

-- Insert into Plan_Usage
INSERT INTO Plan_Usage VALUES ('2024-01-01', '2024-01-31', 500, 1000, 50, '12345678901', 100);
INSERT INTO Plan_Usage VALUES ('2024-02-01', '2024-02-28', 400, 800, 40, '12345678902', 200);
INSERT INTO Plan_Usage VALUES ('2024-03-01', '2024-03-31', 600, 1200, 60, '12345678903', 300);
INSERT INTO Plan_Usage VALUES ('2024-04-01', '2024-04-30', 700, 1400, 70, '12345678904', 400);
INSERT INTO Plan_Usage VALUES ('2024-05-01', '2024-05-31', 800, 1600, 80, '12345678905', 500);

-- Insert into Payment
INSERT INTO Payment VALUES (20.0, '2024-01-10', 'Credit Card', 'Success', '12345678901');
INSERT INTO Payment VALUES (30.0, '2024-02-15', 'Debit Card', 'Failed', '12345678902');
INSERT INTO Payment VALUES (40.0, '2024-03-20', 'PayPal', 'Success', '12345678903');
INSERT INTO Payment VALUES (50.0, '2024-04-25', 'Bank Transfer', 'Pending', '12345678904');
INSERT INTO Payment VALUES (60.0, '2024-05-30', 'Cash', 'Success', '12345678905');

-- Insert into Process_Payment
INSERT INTO Process_Payment VALUES (1, 100);
INSERT INTO Process_Payment VALUES (2, 200);
INSERT INTO Process_Payment VALUES (3, 300);
INSERT INTO Process_Payment VALUES (4, 400);
INSERT INTO Process_Payment VALUES (5, 500);

-- Insert into Wallet
INSERT INTO Wallet VALUES (500.0, 'USD', '2024-01-01', 1, '12345678901');
INSERT INTO Wallet VALUES (1000.0, 'USD', '2024-02-01', 2, '12345678902');
INSERT INTO Wallet VALUES (1500.0, 'USD', '2024-03-01', 3, '12345678903');
INSERT INTO Wallet VALUES (2000.0, 'USD', '2024-04-01', 4, '12345678904');
INSERT INTO Wallet VALUES (2500.0, 'USD', '2024-05-01', 5, '12345678905');

-- Insert into Transfer_money
INSERT INTO Transfer_money VALUES (2, 1, 100.00, '2024-01-15');
INSERT INTO Transfer_money VALUES (3, 2, 200.00, '2024-02-20');
INSERT INTO Transfer_money VALUES (4, 3, 150.00, '2024-03-25');
INSERT INTO Transfer_money VALUES (5, 4, 300.00, '2024-04-30');
INSERT INTO Transfer_money VALUES (1, 5, 250.00, '2024-05-05');

-- Insert into Benefits
INSERT INTO Benefits VALUES ('Free 1GB Data', '2024-12-31', 'Active', '12345678901');
INSERT INTO Benefits VALUES ('Free 100 Minutes', '2024-12-31', 'Active', '12345678902');
INSERT INTO Benefits VALUES ('Discount on Subscription', '2024-12-31', 'Expired', '12345678903');
INSERT INTO Benefits VALUES ('Free 500 SMS', '2024-12-31', 'Active', '12345678904');
INSERT INTO Benefits VALUES ('Bonus Points', '2024-12-31', 'Inactive', '12345678905');

-- Insert into Points_Group
INSERT INTO Points_Group VALUES (1, 50, 1);
INSERT INTO Points_Group VALUES (2, 100, 2);
INSERT INTO Points_Group VALUES (3, 150, 3);
INSERT INTO Points_Group VALUES (4, 200, 4);
INSERT INTO Points_Group VALUES (5, 250, 5);

-- Insert into Exclusive_Offer
INSERT INTO Exclusive_Offer VALUES (1, 500, 100, 50);
INSERT INTO Exclusive_Offer VALUES (2, 1000, 200, 100);
INSERT INTO Exclusive_Offer VALUES (3, 1500, 300, 150);
INSERT INTO Exclusive_Offer VALUES (4, 2000, 400, 200);
INSERT INTO Exclusive_Offer VALUES (5, 2500, 500, 250);

-- Insert into Cashback
INSERT INTO Cashback VALUES (1, 1, 10, '2024-06-01');
INSERT INTO Cashback VALUES (2, 2, 20, '2024-07-01');
INSERT INTO Cashback VALUES (3, 3, 30, '2024-08-01');
INSERT INTO Cashback VALUES (4, 4, 40, '2024-09-01');
INSERT INTO Cashback VALUES (5, 5, 50, '2024-10-01');

-- Insert into Plan_Provides_Benefits
INSERT INTO Plan_Provides_Benefits VALUES (1, 100);
INSERT INTO Plan_Provides_Benefits VALUES (2, 200);
INSERT INTO Plan_Provides_Benefits VALUES (3, 300);
INSERT INTO Plan_Provides_Benefits VALUES (4, 400);
INSERT INTO Plan_Provides_Benefits VALUES (5, 500);

-- Insert into Shop
INSERT INTO Shop VALUES ('Tech Store', 'Electronics');
INSERT INTO Shop VALUES ('Book Haven', 'Books');
INSERT INTO Shop VALUES ('Grocery Plus', 'Groceries');
INSERT INTO Shop VALUES ('Fashion Hub', 'Clothing');
INSERT INTO Shop VALUES ('Gadget World', 'Electronics');

-- Insert into Physical_Shop

INSERT INTO Physical_Shop VALUES (4, '101 Pine St', '11:00 AM - 7:00 PM');
INSERT INTO Physical_Shop VALUES (5, '202 Maple St', '9:30 AM - 8:30 PM');

-- Insert into E_shop
INSERT INTO E_shop VALUES (1, 'www.techstore.com', 5);
INSERT INTO E_shop VALUES (2, 'www.bookhaven.com', 4);
INSERT INTO E_shop VALUES (3, 'www.groceryplus.com', 5);

-- Insert into Voucher
INSERT INTO Voucher VALUES (20, '2024-12-31', 50, '12345678901', 1, '2024-01-01');
INSERT INTO Voucher VALUES (50, '2024-11-30', 100, '12345678902', 2, '2024-02-01');
INSERT INTO Voucher VALUES (30, '2024-10-31', 150, '12345678903', 3, '2024-03-01');
INSERT INTO Voucher VALUES (40, '2024-09-30', 200, '12345678904', 4, '2024-04-01');
INSERT INTO Voucher VALUES (60, '2024-08-31', 250, '12345678905', 5, '2024-05-01');

-- Insert into Technical_Support_Ticket
INSERT INTO Technical_Support_Ticket VALUES ('12345678901', 'Unable to access account', 1, 'Open');
INSERT INTO Technical_Support_Ticket VALUES ('12345678902', 'Payment issue', 2, 'In Progress');
INSERT INTO Technical_Support_Ticket VALUES ('12345678903', 'Subscription activation delay', 3, 'Resolved');
INSERT INTO Technical_Support_Ticket VALUES ('12345678904', 'Data usage not updating', 2, 'Open');
INSERT INTO Technical_Support_Ticket VALUES ('12345678905', 'App crashing frequently', 1, 'In Progress');


truncate table transfer_money
select * from Transfer_money
