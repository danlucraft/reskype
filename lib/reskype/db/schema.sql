
create table "chats" (
	id integer not null primary key,
	name text,
	description text
);

create table "users" (
	id integer not null primary key,
  username text,
	fullname text
);

create table "messages" (
	id integer not null primary key,
	user_id integer,
	chat_id integer,
	body text,
	identities text
);

