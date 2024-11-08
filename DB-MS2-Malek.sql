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



