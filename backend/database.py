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
                    trash_category  VARCHAR(255),
                    confidence      FLOAT,
                    scanned_at      TIMESTAMP DEFAULT NOW()
                );
            """)
            conn.commit()
            print("✅ Database table 'trash_scans' is ready.")
    except Exception as e:
        print(f"❌ Database init error: {e}")
        raise
    finally:
        conn.close()


def save_scan(image_base64: str, has_trash: bool, trash_category: str, confidence: float) -> int:
    """
    Save a trash scan result to the database.
    Returns the ID of the inserted row.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO trash_scans (image_base64, has_trash, trash_category, confidence)
                VALUES (%s, %s, %s, %s)
                RETURNING id;
                """,
                (image_base64, has_trash, trash_category, confidence),
            )
            scan_id = cur.fetchone()[0]
            conn.commit()
            print(f"✅ Saved scan #{scan_id} to database.")
            return scan_id
    except Exception as e:
        conn.rollback()
        print(f"❌ Database save error: {e}")
        raise
    finally:
        conn.close()


def get_all_scans():
    """Get all scan results (for debugging/viewing in pgAdmin)."""
    conn = get_connection()
    try:
        with conn.cursor(row_factory=dict_row) as cur:
            cur.execute("SELECT id, has_trash, trash_category, confidence, scanned_at FROM trash_scans ORDER BY scanned_at DESC;")
            return cur.fetchall()
    finally:
        conn.close()
