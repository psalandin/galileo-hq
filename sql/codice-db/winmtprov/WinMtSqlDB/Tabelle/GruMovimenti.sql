SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TABLE dbo.GruMovimenti
(
    IdMovGru        BIGINT IDENTITY(1,1) NOT NULL,
    CodMac          VARCHAR(20) NOT NULL,
    SlotNo          TINYINT NOT NULL,
    MovementType    VARCHAR(20) NOT NULL,
    PrizeCode       VARCHAR(50) NULL,
    PrizeDesc       VARCHAR(255) NULL,
    Qty             INT NOT NULL,
    UnitValue       DECIMAL(18,4) NOT NULL CONSTRAINT DF_GruMovimenti_UnitValue DEFAULT (0),
    AvgValueBefore  DECIMAL(18,4) NOT NULL CONSTRAINT DF_GruMovimenti_AvgValueBefore DEFAULT (0),
    AvgValueAfter   DECIMAL(18,4) NOT NULL CONSTRAINT DF_GruMovimenti_AvgValueAfter DEFAULT (0),
    QtyBefore       INT NOT NULL CONSTRAINT DF_GruMovimenti_QtyBefore DEFAULT (0),
    QtyAfter        INT NOT NULL CONSTRAINT DF_GruMovimenti_QtyAfter DEFAULT (0),
    OperatorId      INT NULL,
    Note            VARCHAR(255) NULL,
    DataMov         DATETIME NOT NULL CONSTRAINT DF_GruMovimenti_DataMov DEFAULT (GETDATE()),

    CONSTRAINT PK_GruMovimenti PRIMARY KEY (IdMovGru),
    CONSTRAINT CK_GruMovimenti_SlotNo CHECK (SlotNo IN (1,2,3)),
    CONSTRAINT CK_GruMovimenti_MovementType CHECK (MovementType IN ('LOAD','WIN','UNLOAD','ADJUST+','ADJUST-'))
)
GO

ALTER TABLE dbo.GruMagazzinoDettaglio
ADD CONSTRAINT FK_GruMagazzinoDettaglio_GruMagazzino
FOREIGN KEY (CodMac) REFERENCES dbo.GruMagazzino(CodMac);
GO

ALTER TABLE dbo.GruMovimenti
ADD CONSTRAINT FK_GruMovimenti_GruMagazzino
FOREIGN KEY (CodMac) REFERENCES dbo.GruMagazzino(CodMac);
GO