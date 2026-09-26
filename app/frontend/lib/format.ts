type Parts = Record<'weekday' | 'weekdayLong' | 'day' | 'month' | 'monthLong' | 'year', string>

const templates = {
  // 15 Sep 2026
  date: (p: Parts) => `${Number(p.day)} ${p.month} ${p.year}`,
  // 18 Sep
  dayMonth: (p: Parts) => `${Number(p.day)} ${p.month}`,
  // Fri, 2 Oct 2026
  weekday: (p: Parts) => `${p.weekday}, ${Number(p.day)} ${p.month} ${p.year}`,
  // Tuesday, 15 September 2026
  long: (p: Parts) => `${p.weekdayLong}, ${Number(p.day)} ${p.monthLong} ${p.year}`,
  // September 2026
  monthYear: (p: Parts) => `${p.monthLong} ${p.year}`,
  // Sep
  month: (p: Parts) => p.month,
  // 02
  day: (p: Parts) => p.day,
}

function part(date: Date, options: Intl.DateTimeFormatOptions): string {
  // Dates are calendar days, so read them in UTC to avoid shifting by the viewer's timezone.
  return new Intl.DateTimeFormat('en-US', { ...options, timeZone: 'UTC' }).format(date)
}

// Formats an ISO date (YYYY-MM-DD)
export function formatDate(iso: string, style: keyof typeof templates = 'date'): string {
  const date = new Date(iso)
  return templates[style]({
    weekday: part(date, { weekday: 'short' }),
    weekdayLong: part(date, { weekday: 'long' }),
    day: part(date, { day: '2-digit' }),
    month: part(date, { month: 'short' }),
    monthLong: part(date, { month: 'long' }),
    year: part(date, { year: 'numeric' }),
  })
}

export function money(amount: number): string {
  return '$' + amount.toLocaleString('en-US')
}

export function capitalize(text: string): string {
  return text.charAt(0).toUpperCase() + text.slice(1)
}
