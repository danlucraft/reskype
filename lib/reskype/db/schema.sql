
create table "chats" (
	id integer not null,
	name text,
	topic text
);
create index ix_chats_id on chats (id);

create table "users" (
	id integer not null,
  username text,
	fullname text
);
create index ix_users_id on users (id);

create table "messages" (
	id integer not null,
	user_id integer,
	chat_id integer,
	body text,
	identities text,
	created_at datetime
);
create index ix_messages_user_id on messages (user_id, created_at);
create index ix_messages_chat_id on messages (chat_id, created_at);
create index ix_messages_time on messages (created_at);

