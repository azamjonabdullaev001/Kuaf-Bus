-- Add heading column to users table to track driver direction
-- Heading is stored as degrees (0-360), where:
-- 0/360 = North, 90 = East, 180 = South, 270 = West

ALTER TABLE users ADD COLUMN IF NOT EXISTS heading DOUBLE PRECISION;

-- Add index for efficient queries on drivers with heading
CREATE INDEX IF NOT EXISTS idx_users_heading ON users(heading) WHERE user_type = 'driver';

-- Update comment
COMMENT ON COLUMN users.heading IS 'Direction in degrees (0-360): 0=North, 90=East, 180=South, 270=West';
