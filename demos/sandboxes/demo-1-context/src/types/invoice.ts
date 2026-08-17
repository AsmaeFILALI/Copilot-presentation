export type Money = { amountMinor: number; currency: "EUR" | "USD" };

export type LineItem = {
  sku: string;
  description: string;
  quantity: number;
  unitPrice: Money;
};

export type Invoice = {
  invoiceNumber: string;
  customerId: string;
  issuedOn: Date;
  dueOn: Date;
  lines: LineItem[];
  total: Money;
};

export type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: string };
