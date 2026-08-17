def apply_discount(price, percent):
    """Apply a percentage discount to a price.

    Args:
        price: the pre-discount price.
        percent: discount as a whole number, 0-100. 20 means 20% off.

    Returns:
        The discounted price. Never negative.

    Examples:
        apply_discount(100, 20) -> 80
    """
    return price - (price * percent)
