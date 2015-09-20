drop table if exists locations;
create table if not exists locations (
	id int not null auto_increment,
	location_code varchar(20),
	keywords text,
	registered_on date,
	file_path varchar(255),
	created_at timestamp,
	updated_at timestamp,
	primary key(id)
);


