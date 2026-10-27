SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.uid_reservations (
    CodBar      varchar(50) NOT NULL,
    ReservedAt  datetime2(0) NOT NULL CONSTRAINT DF_uid_reservations_ReservedAt DEFAULT (sysdatetime()),
    ReservedBy  varchar(64)  NOT NULL,
    ExpiresAt   datetime2(0) NOT NULL,
    CONSTRAINT PK_uid_reservations PRIMARY KEY (CodBar)
)
GO
CREATE INDEX IX_uid_reservations_ExpiresAt ON dbo.uid_reservations(ExpiresAt)
GO