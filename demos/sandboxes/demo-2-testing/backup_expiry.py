from datetime import datetime


def is_expired(created_at: datetime, ttl_days: int) -> bool:
    """Return True when the item has outlived its TTL."""
    return (datetime.now() - created_at).days > ttl_days
