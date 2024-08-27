use datasyncpoc;
go


create table src (
    id int primary key,
    data varchar(100)
);
go


create table tgt (
    id int,
    data varchar(100),
    created_at datetime default getdate(),
    deleted_at datetime null
);
go

-- Create an index on the id column of the target table
create nonclustered index IX_tgt_id on tgt(id);
go

INSERT INTO src (id, data) VALUES
(1, 'Record 1'),
(2, 'Record 2'),
(3, 'Record 3');
go

insert into src (id, data) values
(4, 'Record 4'),
(5, 'Record 5');

update src
set data = 'Updated Record 1'
where id = 1;

delete from src where id = 1;

EXEC synctables_dev @debug_fl = 1;

DROP PROCEDURE IF EXISTS synctables_dev;
