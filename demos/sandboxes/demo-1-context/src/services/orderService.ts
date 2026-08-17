import { Money, Result } from "../types/invoice";

export function calculateOrderTotal(
  lines: { quantity: number; unitPrice: Money }[]
): Result<Money> {
  if (lines.length === 0) {
    return { ok: false, error: "ORDER_EMPTY" };
  }

  const currency = lines[0].unitPrice.currency;
  const amountMinor = lines.reduce(
    (sum, l) => sum + l.quantity * l.unitPrice.amountMinor,
    0
  );

  return { ok: true, value: { amountMinor, currency } };
}
