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
		mobileNO char(11) primary key identity,
		pass varchar (50),
		balance decimal(10, 1),
		account_type varhcar(50),
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

	CREATE TABLE Subscribtion(
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		planID int foreign key references Service_Plan(planID),
		subscribtion_date date,
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
		mobileNo char(11) foreign key references Customer_Account(mobileNo)            --Foreign Key????
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

--2.2 d                                              ---> What should I display from the Customer_Account?
GO
CREATE VIEW AccountPayments
AS 
	SELECT pay.* , acc.*
	FROM Payment pay 
	JOIN Customer_Account acc ON pay.mobileNo = acc.mobileNo

--2.2 e												 ---> Maybe Should be for both types of shops?
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

--2.2 h													---> Repeated Shops???
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

--2.2 j
GO
CREATE VIEW Num_of_cashback
AS
	SELECT walletID , Count(CashbackID) as cashbacks_per_wallet
	FROM Cashback
	GROUP BY walletID

-------------------------------------------------------------------------------------------------------------------




