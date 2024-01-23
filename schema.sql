-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username text UNIQUE NOT NULL,
    name text,
    bio text,
    link text,
    image_url text,
    is_verified boolean DEFAULT FALSE NOT NULL,
    joined_at timestamp DEFAULT NOW(),
    followers_count integer DEFAULT 0 NOT NULL
);

CREATE TABLE hashtags (
    id SERIAL PRIMARY KEY,
    name text UNIQUE NOT NULL,
    post_count integer DEFAULT 0 NOT NULL
);

CREATE TYPE post_type AS ENUM ('thread', 'reply', 'quote', 'repost');

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    "user" integer NOT NULL REFERENCES users(id),
    content text,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW(),
    likes_count integer DEFAULT 0 NOT NULL,
    replies_count integer DEFAULT 0 NOT NULL,
    quotes_count integer DEFAULT 0 NOT NULL,
    reposts_count integer DEFAULT 0 NOT NULL,
    type post_type NOT NULL,
    thread integer REFERENCES posts(id),
    quote integer REFERENCES posts(id),
    repost integer REFERENCES posts(id)
);

CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    post integer NOT NULL REFERENCES posts(id),
    url text NOT NULL,
    mime_type text NOT NULL,
    size integer NOT NULL,
    metadata jsonb
);

CREATE TABLE links (
    id SERIAL PRIMARY KEY,
    post integer NOT NULL REFERENCES posts(id),
    url text NOT NULL,
    display_url text,
    image_url text,
    title text
);

CREATE TABLE post_like (
    post integer NOT NULL REFERENCES posts(id),
    "like" integer NOT NULL REFERENCES users(id)
);

CREATE TABLE post_mention (
    post integer NOT NULL REFERENCES posts(id),
    mention integer NOT NULL REFERENCES users(id)
);

CREATE TABLE post_hashtag (
    post integer NOT NULL REFERENCES posts(id),
    hashtag integer NOT NULL REFERENCES hashtags(id)
);

CREATE TABLE post_hide (
    post integer NOT NULL REFERENCES posts(id),
    hide integer NOT NULL REFERENCES users(id)
);

CREATE TABLE user_follow (
    "user" integer NOT NULL REFERENCES users(id),
    follow integer NOT NULL REFERENCES users(id)
);

CREATE TABLE user_mute (
    "user" integer NOT NULL REFERENCES users(id),
    mute integer NOT NULL REFERENCES users(id)
);

CREATE TABLE user_block (
    "user" integer NOT NULL REFERENCES users(id),
    block integer NOT NULL REFERENCES users(id)
);
