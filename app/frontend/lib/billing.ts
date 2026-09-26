import { formatDate } from '@/lib/format'
import type { Bill } from '@/types/headquarter'

export type BillMonth = { label: string; total: number; bills: Bill[] }

// Groups bills (already sorted by date) under their calendar month
export function groupByMonth(bills: Bill[]): BillMonth[] {
  const months = new Map<string, BillMonth>()
  for (const bill of bills) {
    const key = bill.date.slice(0, 7)
    const month = months.get(key) ?? {
      label: formatDate(bill.date, 'monthYear'),
      total: 0,
      bills: [],
    }
    month.total += bill.amount
    month.bills.push(bill)
    months.set(key, month)
  }
  return [...months.values()]
}
