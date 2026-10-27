SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.PartiteOspiti (
    IdContatto bigint NOT NULL,
    device varchar(16) COLLATE Latin1_General_CI_AS NOT NULL,
    DataUltimaPartita datetime NULL,
    NrPartiteConsecutive int NULL CONSTRAINT DF_PartiteOspiti_NrPartiteConsecutive DEFAULT 0,
    TotPartite int NULL CONSTRAINT DF_PartiteOspiti_TotPartite DEFAULT 0,
    TotTickets int NULL CONSTRAINT DF_PartiteOspiti_TotTickets DEFAULT 0,
    CreatedBy bigint NULL,
    CreatedAt datetime2(7) NULL,
    UpdatedBy bigint NULL,
    UpdatedAt datetime2(7) NULL,
    id bigint IDENTITY(1,1) NOT NULL,

    CONSTRAINT PK_PartiteOspiti PRIMARY KEY CLUSTERED (id)
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PartiteOspiti] SET (LOCK_ESCALATION = TABLE)
GO

CREATE NONCLUSTERED INDEX [PartiteOspiti]
ON [dbo].[PartiteOspiti] (
  [IdContatto] ASC,
  [device] ASC
)