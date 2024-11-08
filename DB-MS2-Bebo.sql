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

END;

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




