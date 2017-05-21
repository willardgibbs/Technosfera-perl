CREATE TABLE `artists` (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `country` VARCHAR(2) NOT NULL,
  `create_time` TIMESTAMP NOT NULL
);
CREATE INDEX name_index ON artists (name);

CREATE TABLE `tracks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `album_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `extension` INT NOT NULL,
  `create_time` TIMESTAMP NOT NULL
);
CREATE INDEX album_id_index ON tracks (album_id);
CREATE INDEX name_index ON tracks (name);

CREATE TABLE `albums` (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `artist_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `year` INT NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `create_time` TIMESTAMP NOT NULL
);
CREATE INDEX name_index ON albums (name);
CREATE INDEX type_index ON albums (type);
CREATE INDEX artist_id_index ON albums (artist_id);