<script lang="ts">
  import PageHeader from '@/components/PageHeader.svelte'
  import Segmented from '@/components/Segmented.svelte'
  import Badge from '@/components/Badge.svelte'
  import { groupByMonth } from '@/lib/billing'
  import { formatDate, money } from '@/lib/format'
  import { billKindLabel, billKindTone } from '@/lib/tones'
  import type { Bill, BillingSummary } from '@/types/headquarter'

  let { summary, bills }: { summary: BillingSummary; bills: Bill[] } = $props()

  type Filter = 'all' | 'recurring' | 'one_time'
  let filter = $state<Filter>('all')
  let expanded = $state<number | null>(null)

  const filters: { value: Filter; label: string }[] = [
    { value: 'all', label: 'All' },
    { value: 'recurring', label: 'Subscriptions' },
    { value: 'one_time', label: 'One-time' },
  ]

  const months = $derived(
    groupByMonth(
      bills.filter(
        (bill) => filter === 'all' || (filter === 'one_time') === (bill.kind === 'one_time'),
      ),
    ),
  )

  const details = (bill: Bill) => [
    ['Invoice no.', bill.invoice_no],
    ['Account', bill.account],
    ['Paid via', bill.method],
    ['Source', bill.source],
  ]
</script>

<PageHeader eyebrow="Subscriptions & billing" title="Next 90 days">
  {#snippet aside()}
    <Segmented items={filters} active={filter} onselect={(value) => (filter = value)} />
  {/snippet}
</PageHeader>

<div class="flex flex-col gap-6">
  <div class="grid grid-cols-[repeat(auto-fit,minmax(240px,1fr))] gap-4">
    <div class="rounded-[20px] bg-ink p-[22px] text-white">
      <div class="text-[13px] font-semibold text-faint">Total due</div>
      <div class="mt-2 text-4xl font-bold tracking-[-0.03em] tabular-nums">
        {money(summary.total)}
      </div>
      <div class="mt-1.5 text-[12.5px] text-faint">{summary.count} payments</div>
    </div>
    <div class="rounded-[20px] border border-rule bg-white p-[22px]">
      <div class="text-[13px] font-semibold text-muted">Recurring</div>
      <div class="mt-2 text-4xl font-bold tracking-[-0.03em] tabular-nums">
        {money(summary.recurring)}
      </div>
      <div class="mt-1.5 text-[12.5px] text-muted">Subscriptions and usage</div>
    </div>
    <div class="rounded-[20px] border border-rule bg-white p-[22px]">
      <div class="text-[13px] font-semibold text-muted">One-time</div>
      <div class="mt-2 text-4xl font-bold tracking-[-0.03em] tabular-nums">
        {money(summary.one_time)}
      </div>
      <div class="mt-1.5 text-[12.5px] text-muted">Contractors, audits, renewals</div>
    </div>
  </div>

  <div class="flex flex-col gap-4">
    {#each months as month (month.label)}
      <section class="rounded-[20px] border border-rule bg-white px-[22px] py-1.5">
        <div class="flex items-baseline justify-between pt-4 pb-2">
          <h2 class="text-base font-bold">{month.label}</h2>
          <span class="text-sm font-bold tabular-nums">{money(month.total)}</span>
        </div>
        {#each month.bills as bill (bill.id)}
          <div class="border-t border-hairline">
            <button
              type="button"
              aria-expanded={expanded === bill.id}
              onclick={() => (expanded = expanded === bill.id ? null : bill.id)}
              class="grid w-full cursor-pointer grid-cols-[40px_minmax(0,1.6fr)_90px] items-center gap-x-4 gap-y-2 py-3 text-left sm:grid-cols-[40px_minmax(0,1.6fr)_minmax(90px,1fr)_90px]"
            >
              <div class="text-[13px] font-semibold text-muted tabular-nums">
                {formatDate(bill.date, 'day')}
              </div>
              <div class="min-w-0">
                <div class="text-[14.5px] font-semibold">{bill.platform}</div>
                <div class="flex flex-wrap items-center gap-2 text-[12.5px] text-muted">
                  <span>{bill.description}</span>
                  {#if bill.file}
                    <span
                      class="inline-flex items-center gap-1 rounded-full bg-accent-soft px-2 py-px text-[11px] font-bold text-accent"
                    >
                      ⎘ Invoice
                    </span>
                  {/if}
                </div>
              </div>
              <span class="max-sm:hidden">
                <Badge tone={billKindTone[bill.kind]}>{billKindLabel[bill.kind]}</Badge>
              </span>
              <div class="text-right text-[15px] font-semibold tabular-nums">
                {money(bill.amount)}
              </div>
            </button>

            {#if expanded === bill.id}
              <div
                class="mb-3.5 grid animate-fade-in grid-cols-[repeat(auto-fit,minmax(150px,1fr))] gap-x-5 gap-y-3.5 rounded-[14px] bg-canvas px-[18px] py-4"
              >
                {#each details(bill) as [label, value] (label)}
                  <div>
                    <div class="mb-1 text-[11px] font-bold tracking-[.04em] text-muted uppercase">
                      {label}
                    </div>
                    <div class="text-[13.5px] font-medium wrap-anywhere">{value || '—'}</div>
                  </div>
                {/each}
                <div class="col-span-full border-t border-rule pt-3">
                  <div class="mb-1.5 text-[11px] font-bold tracking-[.04em] text-muted uppercase">
                    Attachment
                  </div>
                  {#if bill.file}
                    <a
                      href={bill.file.url ?? '#'}
                      target="_blank"
                      rel="noopener"
                      download={bill.file.name}
                      class="inline-flex max-w-full items-center gap-3 rounded-xl border border-rule bg-white px-3.5 py-2.5 hover:border-accent"
                    >
                      <span
                        class="grid size-[34px] shrink-0 place-items-center rounded-[10px] bg-accent-soft text-[10px] font-extrabold text-accent"
                      >
                        PDF
                      </span>
                      <span class="min-w-0">
                        <span class="block truncate text-[13.5px] font-semibold">
                          {bill.file.name}
                        </span>
                        <span class="block text-xs text-muted">{bill.file.meta}</span>
                      </span>
                      <span class="ml-1.5 text-xs font-bold whitespace-nowrap text-accent">
                        Open ↗
                      </span>
                    </a>
                  {:else}
                    <div class="text-[13px] text-faint">No invoice or receipt attached.</div>
                  {/if}
                </div>
              </div>
            {/if}
          </div>
        {/each}
      </section>
    {/each}
  </div>
</div>
