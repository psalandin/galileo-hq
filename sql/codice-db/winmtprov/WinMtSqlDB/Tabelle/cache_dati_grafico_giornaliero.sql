SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[cache_dati_grafico_giornaliero] (
    [CodMac] varchar(15) COLLATE Latin1_General_CI_AS NOT NULL,
    [tipo] int NULL,
    [DataRil] date NOT NULL,
    [EUIncassiMonete] money NULL,
    [EUIncassiGettoni] money NULL,
    [EUPremiPagati] money NULL,
    [EUTicketsPagati] money NULL,
    [NrMonete] bigint NULL,
    [NrGettoni] bigint NULL,
    [NrPremi] bigint NULL,
    [NrTickets] bigint NULL,
    [NrGettoniOut] bigint NULL,
    [NrMoneteOut] money NULL,
    [NPartite] numeric(10,1) NULL,
    CONSTRAINT [PK_cache_dati_grafico_giornaliero] PRIMARY KEY CLUSTERED 
    (
        [CodMac] ASC,
        [DataRil] ASC
    )
    WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [PRIMARY]
) ON [PRIMARY];
GO
