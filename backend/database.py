"""
PostgreSQL database connection and operations for Trashy.
"""
import psycopg
from psycopg.rows import dict_row

# ============================================================
# EDIT THESE to match your PostgreSQL setup
# ============================================================
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "trashy_db",      # Create this database in pgAdmin first
    "user": "postgres",          # Your PostgreSQL username
    "password": "1",             # Your PostgreSQL password
}
# ============================================================


def get_connection():
    """Get a new database connection."""
    return psycopg.connect(**DB_CONFIG)


def init_db():
    """Create the trash_scans table if it doesn't exist."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS trash_scans (
                    id             SERIAL PRIMARY KEY,
                    image_base64   TEXT NOT NULL,
                    has_trash       BOOLEAN,
                    trash_type      VARCHAR(50),
                    trash_category  VARCHAR(255),
                    confidence      FLOAT,
                    bin_color       VARCHAR(50),
                    instruction     TEXT,
                    scanned_at      TIMESTAMP DEFAULT NOW()
                );
            """)
            # Add new columns if they don't exist yet (for existing databases)
            for col, col_type in [
                ("trash_type", "VARCHAR(50)"),
                ("bin_color",  "VARCHAR(50)"),
                ("instruction", "TEXT"),
            ]:
                cur.execute(f"""
                    DO $$ BEGIN
                        ALTER TABLE trash_scans ADD COLUMN IF NOT EXISTS {col} {col_type};
                    EXCEPTION WHEN duplicate_column THEN NULL;
                    END $$;
                """)
            conn.commit()
            print("Database table 'trash_scans' is ready.")
    except Exception as e:
        print(f"Database init error: {e}")
        raise
    finally:
        conn.close()


def save_scan(
    image_base64: str,
    has_trash: bool,
    trash_type: str,
    trash_category: str,
    confidence: float,
    bin_color: str,
    instruction: str,
) -> int:
    """
    Save a trash scan result to the database.
    Returns the ID of the inserted row.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO trash_scans
                    (image_base64, has_trash, trash_type, trash_category, confidence, bin_color, instruction)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id;
                """,
                (image_base64, has_trash, trash_type, trash_category, confidence, bin_color, instruction),
            )
            scan_id = cur.fetchone()[0]
            conn.commit()
            print(f"Saved scan #{scan_id} to database.")
            return scan_id
    except Exception as e:
        conn.rollback()
        print(f"Database save error: {e}")
        raise
    finally:
        conn.close()


def get_all_scans():
    """Get all scan results (for debugging/viewing in pgAdmin)."""
    conn = get_connection()
    try:
        with conn.cursor(row_factory=dict_row) as cur:
            cur.execute("""
                SELECT id, has_trash, trash_type, trash_category, confidence,
                       bin_color, instruction, scanned_at
                FROM trash_scans ORDER BY scanned_at DESC;
            """)
            return cur.fetchall()
    finally:
        conn.close()
