CREATE DATABASE TELECOM_TEAM_126 


GO
CREATE PROC createAllTables
AS
Begin

--------------- Rest of 2.1 create all tables
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

---------------- END OF 2.1 CREATE ALL TABLES
END


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


--------------------------------2.2 a
GO
CREATE VIEW allCustomerAccounts AS
SELECT 
    cp.nationalID,
    cp.first_name,
    cp.last_name,
    cp.email,
    cp.address,
    cp.date_of_birth,
    ca.mobileNo,
    ca.balance,
    ca.account_type,
    ca.start_date,
    ca.status,
    ca.point
FROM 
    Customer_profile AS cp
JOIN 
    Customer_Account AS ca
ON 
    cp.nationalID = ca.nationalID
WHERE 
    ca.status = 'active';
--------------------------------------2.2 a END


-----------------------------------2.2 b
GO
CREATE VIEW allServicePlans AS
SELECT 
    planID,
    SMS_offered,
    minutes_offered,
    data_offered,
    name,
    price,
    description
FROM 
    Service_Plan;
--------------------------------------2.2 b END


-----------------------------------2.2 c
GO
CREATE VIEW allBenefits AS
SELECT 
    benefitID,
    description,
    validity_date,
    status,
    mobileNo
FROM 
    Benefits
WHERE 
    status = 'active';
----------------------------------------2.2 c END


------------------------------------2.2 D
GO
CREATE VIEW AccountPayments AS
SELECT 
    p.paymentID,
    p.amount,
    p.date_of_payment,
    p.payment_method,
    p.status AS payment_status,
    p.mobileNo,
    ca.balance,
    ca.account_type,
    ca.status AS account_status
FROM 
    Payment AS p
JOIN 
    Customer_Account AS ca
ON 
    p.mobileNo = ca.mobileNo;
--------------------------------------------2.2 D END