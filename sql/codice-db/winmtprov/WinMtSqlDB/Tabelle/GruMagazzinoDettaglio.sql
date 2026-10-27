SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.GruMagazzinoDettaglio
(
    CodMac         VARCHAR(20) NOT NULL,
    SlotNo         TINYINT NOT NULL,
    QtyCurrent     INT NOT NULL CONSTRAINT DF_GruMagazzinoDettaglio_QtyCurrent DEFAULT (0),
    AvgValue       DECIMAL(18,4) NOT NULL CONSTRAINT DF_GruMagazzinoDettaglio_AvgValue DEFAULT (0),
    LastLoadDate   DATETIME NULL,
    LastWinDate    DATETIME NULL,
    UpdatedAt      DATETIME NOT NULL CONSTRAINT DF_GruMagazzinoDettaglio_UpdatedAt DEFAULT (GETDATE()),

    CONSTRAINT PK_GruMagazzinoDettaglio PRIMARY KEY (CodMac, SlotNo),
    CONSTRAINT CK_GruMagazzinoDettaglio_SlotNo CHECK (SlotNo IN (1,2,3)),
    CONSTRAINT CK_GruMagazzinoDettaglio_QtyCurrent CHECK (QtyCurrent >= 0),
    CONSTRAINT CK_GruMagazzinoDettaglio_AvgValue CHECK (AvgValue >= 0)
)
GO
