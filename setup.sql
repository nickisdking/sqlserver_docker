IF EXISTS (SELECT name FROM sys.databases WHERE name = 'trades')
BEGIN
    ALTER DATABASE trades SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE trades;
END
GO

CREATE DATABASE trades;
GO

USE trades;
GO

CREATE TABLE trade_execution (
    trade_id INT IDENTITY(1,1) PRIMARY KEY,
    symbol NVARCHAR(50) NOT NULL,
    quantity DECIMAL(18,2) NOT NULL,
    price DECIMAL(18,4) NOT NULL,
    side NVARCHAR(4) NOT NULL CHECK (side IN ('BUY', 'SELL')),
    execution_time DATETIME2 NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'EXECUTED',
    notes NVARCHAR(200)
);
GO

-- Create index for faster queries
CREATE INDEX idx_trade_execution_time ON trade_execution(execution_time);
CREATE INDEX idx_trade_symbol ON trade_execution(symbol);
GO

-- Insert 10,000 sample rows
DECLARE @i INT = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO trade_execution (symbol, quantity, price, side, notes)
    VALUES (
        CHAR(65 + RAND() * 26) + CHAR(65 + RAND() * 26),
        RAND() * 10000 + 100,
        RAND() * 100 + 10,
        CASE WHEN RAND() > 0.5 THEN 'BUY' ELSE 'SELL' END,
        'Sample trade ' + CAST(@i AS VARCHAR(10))
    );
    SET @i = @i + 1;
END
GO

-- Create SQL Server Agent job to run setup
USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Setup Database')
EXEC msdb.dbo.sp_delete_job @job_name=N'Setup Database';
GO

EXEC msdb.dbo.sp_add_job @job_name=N'Setup Database';
GO

EXEC msdb.dbo.sp_add_jobstep @job_name=N'Setup Database',
    @step_name=N'Run Setup Script',
    @subsystem=N'TSQL',
    @command=N'
    USE master;
    GO
    EXEC sp_executesql N''
    IF EXISTS (SELECT name FROM sys.databases WHERE name = ''''trades'''')
    BEGIN
        ALTER DATABASE trades SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE trades;
    END
    GO
    CREATE DATABASE trades;
    GO
    USE trades;
    GO
    CREATE TABLE trade_execution (
        trade_id INT IDENTITY(1,1) PRIMARY KEY,
        symbol NVARCHAR(50) NOT NULL,
        quantity DECIMAL(18,2) NOT NULL,
        price DECIMAL(18,4) NOT NULL,
        side NVARCHAR(4) NOT NULL CHECK (side IN (''BUY'', ''SELL'')),
        execution_time DATETIME2 NOT NULL DEFAULT GETDATE(),
        status NVARCHAR(20) NOT NULL DEFAULT ''EXECUTED'',
        notes NVARCHAR(200)
    );
    GO
    CREATE INDEX idx_trade_execution_time ON trade_execution(execution_time);
    CREATE INDEX idx_trade_symbol ON trade_execution(symbol);
    GO
    DECLARE @i INT = 1;
    WHILE @i <= 10000
    BEGIN
        INSERT INTO trade_execution (symbol, quantity, price, side, notes)
        VALUES (
            CHAR(65 + RAND() * 26) + CHAR(65 + RAND() * 26),
            RAND() * 10000 + 100,
            RAND() * 100 + 10,
            CASE WHEN RAND() > 0.5 THEN ''BUY'' ELSE ''SELL'' END,
            ''Sample trade '' + CAST(@i AS VARCHAR(10))
        );
        SET @i = @i + 1;
    END
    GO
    ''',
    @retry_attempts=0,
    @retry_interval=0;
GO

EXEC msdb.dbo.sp_add_jobserver @job_name=N'Setup Database';
GO

EXEC msdb.dbo.sp_start_job N'Setup Database';
GO

-- Wait for job to complete
WAITFOR DELAY '00:00:30';
GO

CREATE DATABASE trades;
GO

USE trades;
GO

CREATE TABLE trade_execution (
    trade_id INT IDENTITY(1,1) PRIMARY KEY,
    symbol NVARCHAR(50) NOT NULL,
    quantity DECIMAL(18,2) NOT NULL,
    price DECIMAL(18,4) NOT NULL,
    side NVARCHAR(4) NOT NULL CHECK (side IN ('BUY', 'SELL')),
    execution_time DATETIME2 NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'EXECUTED',
    notes NVARCHAR(200)
);
GO

-- Create index for faster queries
CREATE INDEX idx_trade_execution_time ON trade_execution(execution_time);
CREATE INDEX idx_trade_symbol ON trade_execution(symbol);
GO

-- Insert 10,000 sample rows
DECLARE @i INT = 1;
DECLARE @symbols TABLE (symbol NVARCHAR(50));
INSERT INTO @symbols VALUES ('AAPL'), ('GOOGL'), ('MSFT'), ('AMZN'), ('META');

WHILE @i <= 10000
BEGIN
    DECLARE @symbol NVARCHAR(50);
    DECLARE @side NVARCHAR(4);
    DECLARE @quantity DECIMAL(18,2);
    DECLARE @price DECIMAL(18,4);
    DECLARE @notes NVARCHAR(200);
    
    -- Randomly select a symbol
    SELECT @symbol = symbol FROM @symbols ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Randomly select side
    SET @side = CASE WHEN RAND() < 0.5 THEN 'BUY' ELSE 'SELL' END;
    
    -- Randomly generate quantity (100-10000)
    SET @quantity = CAST(100 + (RAND() * 9900) AS DECIMAL(18,2));
    
    -- Randomly generate price (100-1000)
    SET @price = CAST(100 + (RAND() * 900) AS DECIMAL(18,4));
    
    -- Randomly generate notes
    SET @notes = CASE 
        WHEN RAND() < 0.3 THEN 'Market order'
        WHEN RAND() < 0.6 THEN 'Limit order'
        ELSE 'Stop order'
    END;
    
    INSERT INTO trade_execution (symbol, quantity, price, side, execution_time, status, notes)
    VALUES (@symbol, @quantity, @price, @side, DATEADD(SECOND, CAST(RAND() * 3600 AS INT), GETDATE()), 'EXECUTED', @notes);
    
    SET @i = @i + 1;
END;
GO

-- Verify the data was inserted
SELECT COUNT(*) FROM trade_execution;
GO

-- Show some sample data
SELECT TOP 5 * FROM trade_execution ORDER BY trade_id DESC;
GO

-- Show statistics about the data
SELECT 
    symbol,
    COUNT(*) as trade_count,
    SUM(quantity) as total_quantity,
    AVG(price) as avg_price,
    SUM(CASE WHEN side = 'BUY' THEN quantity ELSE 0 END) as buy_quantity,
    SUM(CASE WHEN side = 'SELL' THEN quantity ELSE 0 END) as sell_quantity
FROM trade_execution
GROUP BY symbol
ORDER BY trade_count DESC;
GO
