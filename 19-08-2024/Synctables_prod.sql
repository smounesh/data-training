create procedure synctables_prod
as
begin
    -- Step 1: Insert updated records as new entries
    insert into tgt (id, data, created_at, deleted_at)
    select source.id, source.data, getdate(), null
    from src as source
    left join tgt as target on target.id = source.id
    where target.id is not null and target.data <> source.data;

    -- Step 2: Insert new records from src to tgt
    insert into tgt (id, data, created_at, deleted_at)
    select source.id, source.data, getdate(), null
    from src as source
    left join tgt as target on target.id = source.id
    where target.id is null;

    -- Step 3: Handle soft deletes
    update tgt
    set deleted_at = getdate()
    from tgt
    left join src on tgt.id = src.id
    where src.id is null;
end;
go
