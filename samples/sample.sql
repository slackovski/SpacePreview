-- Users table
CREATE TABLE users (
  id         BIGINT       PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(255) NOT NULL UNIQUE,
  role       ENUM('admin','editor','viewer') NOT NULL DEFAULT 'viewer',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME     NULL,
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);

-- Posts table
CREATE TABLE posts (
  id         BIGINT       PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  title      VARCHAR(200) NOT NULL,
  content    TEXT         NOT NULL,
  published  BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Query: active users with post count
SELECT
  u.id,
  u.name,
  COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id AND p.published = TRUE
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.name
ORDER BY post_count DESC
LIMIT 10;
