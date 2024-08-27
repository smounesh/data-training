CREATE PROCEDURE synctables_dev
    @debug_fl BIT = 0  -- Debug flag: 0 for production, 1 for development
AS
BEGIN
    -- Debugging information
    IF @debug_fl = 1
    BEGIN
        PRINT 'Debug mode: synchronization started';
    END

    -- Step 1: Prepare and print records that would be inserted as updates
    IF @debug_fl = 1
    BEGIN
        PRINT 'Records that will be inserted as updated entries:';
        SELECT source.id, source.data
        FROM src AS source
        LEFT JOIN tgt AS target ON target.id = source.id
        WHERE target.id IS NOT NULL AND target.data <> source.data;
    END

    -- Insert updated records as new entries
    INSERT INTO tgt (id, data, created_at, deleted_at)
    SELECT source.id, source.data, GETDATE(), NULL
    FROM src AS source
    LEFT JOIN tgt AS target ON target.id = source.id
    WHERE target.id IS NOT NULL AND target.data <> source.data;

    -- Step 2: Prepare and print new records to be inserted
    IF @debug_fl = 1
    BEGIN
        PRINT 'Records that will be inserted as new entries:';
        SELECT source.id, source.data
        FROM src AS source
        LEFT JOIN tgt AS target ON target.id = source.id
        WHERE target.id IS NULL;
    END

    -- Insert new records from src to tgt
    INSERT INTO tgt (id, data, created_at, deleted_at)
    SELECT source.id, source.data, GETDATE(), NULL
    FROM src AS source
    LEFT JOIN tgt AS target ON target.id = source.id
    WHERE target.id IS NULL;

    -- Step 3: Prepare and print records that will be marked as deleted
    IF @debug_fl = 1
    BEGIN
        PRINT 'Records that will be marked as deleted:';
        SELECT tgt.id, tgt.data
        FROM tgt
        LEFT JOIN src ON tgt.id = src.id
        WHERE src.id IS NULL;
    END

    -- Update records to mark them as deleted
    UPDATE tgt
    SET deleted_at = GETDATE()
    OUTPUT 'DELETE', inserted.id, inserted.data, inserted.deleted_at
    FROM tgt
    LEFT JOIN src ON tgt.id = src.id
    WHERE src.id IS NULL;

    -- Debugging information
    IF @debug_fl = 1
    BEGIN
        PRINT 'Debug mode: synchronization completed';
    END
END;
GO
