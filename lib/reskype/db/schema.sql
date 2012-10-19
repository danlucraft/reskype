
create table "chats" (
	id integer not null,
	name text,
	topic text
);

create table "users" (
	id integer not null primary key,
  username text,
	fullname text
);

create table "messages" (
	id integer not null,
	user_id integer,
	chat_id integer,
	body text,
	identities text,
	created_at datetime
);

