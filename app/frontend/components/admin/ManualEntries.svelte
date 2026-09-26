<script lang="ts">
  import { untrack } from 'svelte'
  import Segmented from '@/components/Segmented.svelte'
  import { formatDate, money } from '@/lib/format'
  import { fieldInput, fieldLabel, primaryButton, removeButton } from '@/lib/ui'
  import type { Bill, BillKind, ManualArea } from '@/types/headquarter'

  let { areas: initialAreas, bills: initialBills }: { areas: ManualArea[]; bills: Bill[] } =
    $props()

  let areas = $state(untrack(() => $state.snapshot(initialAreas)))
  let bills = $state(untrack(() => $state.snapshot(initialBills)))
  // Billing opens first: it is the area edited most often
  let activeId = $state(
    untrack(() =>
      initialAreas.some((area) => area.id === 'billing') ? 'billing' : initialAreas[0]?.id,
    ),
  )
  let draft = $state('')
  let editing = $state<number | null>(null)
  let editValue = $state('')

  const area = $derived(areas.find((candidate) => candidate.id === activeId))
  const count = (candidate: ManualArea) =>
    candidate.id === 'billing'
      ? bills.filter((bill) => bill.source === 'Manual').length
      : candidate.items.length

  function select(id: string) {
    activeId = id
    editing = null
  }

  function addItem() {
    const text = draft.trim()
    if (!text || !area) return
    area.items.push(text)
    draft = ''
  }

  function commitEdit() {
    const text = editValue.trim()
    if (area && editing !== null && text) area.items[editing] = text
    editing = null
  }

  // Billing entry form
  const blankBill = {
    platform: '',
    description: '',
    date: '',
    amount: '',
    invoice_no: '',
    account: '',
    method: '',
    kind: 'subscription' as BillKind,
  }
  let bill = $state({ ...blankBill })
  let billFile = $state<{ name: string; meta: string; url: string } | null>(null)
  let billError = $state(false)

  const kinds: { value: BillKind; label: string }[] = [
    { value: 'subscription', label: 'Subscription' },
    { value: 'usage', label: 'Usage' },
    { value: 'one_time', label: 'One-time' },
  ]

  const billFields: {
    key: Exclude<keyof typeof blankBill, 'kind'>
    label: string
    placeholder: string
    type?: string
  }[] = [
    { key: 'platform', label: 'Vendor', placeholder: 'e.g. SOC 2 audit' },
    { key: 'description', label: 'Description', placeholder: 'Type I engagement · deposit' },
    { key: 'date', label: 'Due date', placeholder: '', type: 'date' },
    { key: 'amount', label: 'Amount (USD)', placeholder: '7,500' },
    { key: 'invoice_no', label: 'Invoice no.', placeholder: 'PRE-2026-118' },
    { key: 'account', label: 'Account / payee', placeholder: 'ops@halden.ai or company name' },
    { key: 'method', label: 'Paid via', placeholder: 'Card •• 4021, bank transfer…' },
  ]

  function attach(event: Event) {
    const file = (event.currentTarget as HTMLInputElement).files?.[0]
    if (!file) return
    const size =
      file.size > 1e6
        ? `${(file.size / 1e6).toFixed(1)} MB`
        : `${Math.max(1, Math.round(file.size / 1024))} KB`
    const type = (file.type || 'file').split('/').pop()?.toUpperCase()
    billFile = { name: file.name, meta: `${type} · ${size}`, url: URL.createObjectURL(file) }
  }

  function addBill() {
    const amount = parseFloat(bill.amount.replace(/[^0-9.]/g, ''))
    if (!bill.platform.trim() || !bill.date || !(amount > 0)) {
      billError = true
      return
    }
    bills.unshift({
      id: Math.max(0, ...bills.map((b) => b.id)) + 1,
      date: bill.date,
      platform: bill.platform.trim(),
      description: bill.description.trim() || kinds.find((k) => k.value === bill.kind)!.label,
      kind: bill.kind,
      amount,
      invoice_no: bill.invoice_no.trim() || undefined,
      account: bill.account.trim() || undefined,
      method: bill.method.trim() || undefined,
      source: 'Manual',
      file: billFile ?? undefined,
    })
    bill = { ...blankBill }
    billFile = null
    billError = false
  }
</script>

<div class="flex flex-wrap items-start gap-4">
  <div class="flex max-w-[240px] flex-[1_1_200px] flex-col gap-1 max-sm:max-w-none">
    {#each areas as candidate (candidate.id)}
      <button
        type="button"
        onclick={() => select(candidate.id)}
        class={[
          'flex cursor-pointer justify-between rounded-xl border px-3.5 py-2.5 text-left text-sm font-semibold',
          candidate.id === activeId ? 'border-rule bg-white' : 'border-transparent',
        ]}
      >
        <span>{candidate.label}</span>
        <span class="text-xs text-muted tabular-nums">{count(candidate)}</span>
      </button>
    {/each}
  </div>

  {#if area}
    <div class="min-w-0 flex-[3_1_320px] rounded-[20px] border border-rule bg-white p-[22px]">
      <div class="mb-3.5 flex flex-wrap items-baseline justify-between gap-3">
        <h2 class="text-lg font-bold">{area.label}</h2>
        <span class="text-[13px] text-muted">{area.hint}</span>
      </div>

      {#if area.id === 'billing'}
        <form
          class="mb-[18px] flex flex-col gap-3.5 rounded-2xl border border-rule bg-well p-[18px]"
          onsubmit={(event) => {
            event.preventDefault()
            addBill()
          }}
        >
          <div class="grid grid-cols-[repeat(auto-fit,minmax(180px,1fr))] gap-3">
            {#each billFields as field (field.key)}
              <label class={fieldLabel}>
                {field.label}
                <input
                  type={field.type ?? 'text'}
                  bind:value={bill[field.key]}
                  oninput={() => (billError = false)}
                  placeholder={field.placeholder}
                  class={[fieldInput, 'bg-white']}
                />
              </label>
            {/each}
            <div class={[fieldLabel, 'col-span-full']}>
              Type
              <Segmented
                items={kinds}
                active={bill.kind}
                size="sm"
                onselect={(value) => (bill.kind = value)}
              />
            </div>
          </div>

          <div class={fieldLabel}>
            Invoice or receipt
            {#if billFile}
              <div
                class="flex items-center gap-3 rounded-xl border border-rule bg-white px-3.5 py-2.5"
              >
                <span
                  class="grid size-[34px] shrink-0 place-items-center rounded-[10px] bg-accent-soft text-[10px] font-extrabold text-accent"
                >
                  FILE
                </span>
                <span class="min-w-0 flex-1">
                  <span class="block truncate text-[13.5px] font-semibold">{billFile.name}</span>
                  <span class="block text-xs font-medium text-muted">{billFile.meta}</span>
                </span>
                <button type="button" onclick={() => (billFile = null)} class={removeButton}>
                  Remove
                </button>
              </div>
            {:else}
              <label
                class="flex cursor-pointer items-center justify-center gap-2 rounded-xl border-[1.5px] border-dashed border-edge bg-white p-4 text-[13.5px] font-semibold text-muted hover:border-accent hover:text-accent"
              >
                <input type="file" accept=".pdf,image/*" class="hidden" onchange={attach} />
                ⎘ Attach PDF or image
                <span class="font-medium text-faint">· shown on the public Billing page</span>
              </label>
            {/if}
          </div>

          <div class="flex flex-wrap items-center justify-between gap-3">
            {#if billError}
              <span class="text-[13px] font-medium text-down">
                Vendor, due date and an amount are required.
              </span>
            {/if}
            <button class={[primaryButton, 'ml-auto']}>Add entry</button>
          </div>
        </form>

        {#each bills as entry (entry.id)}
          <div
            class="grid grid-cols-[minmax(0,1.6fr)_minmax(90px,1fr)_80px_auto] items-center gap-x-3.5 gap-y-2 border-t border-hairline py-3 text-sm"
          >
            <div class="min-w-0">
              <div class="flex flex-wrap items-center gap-2 font-semibold">
                <span>{entry.platform}</span>
                {#if entry.file}
                  <a
                    href={entry.file.url ?? '#'}
                    target="_blank"
                    rel="noopener"
                    class="rounded-full bg-accent-soft px-2 py-px text-[11px] font-bold text-accent"
                  >
                    ⎘ {entry.file.name}
                  </a>
                {/if}
              </div>
              <div class="text-[12.5px] text-muted">
                {formatDate(entry.date)} · {entry.description}
              </div>
            </div>
            <span
              class="w-fit rounded-full border border-rule bg-canvas px-2.5 py-0.5 text-[11px] font-semibold whitespace-nowrap text-muted"
            >
              {entry.source}
            </span>
            <div class="text-right font-semibold tabular-nums">{money(entry.amount)}</div>
            <button
              type="button"
              onclick={() => (bills = bills.filter((b) => b.id !== entry.id))}
              class={removeButton}
            >
              Remove
            </button>
          </div>
        {/each}
      {:else}
        <form
          class="mb-3 grid grid-cols-[minmax(0,1fr)_auto] gap-2"
          onsubmit={(event) => {
            event.preventDefault()
            addItem()
          }}
        >
          <input bind:value={draft} placeholder={area.placeholder} class={fieldInput} />
          <button class={[primaryButton, 'px-4 text-[13px]']}>Add</button>
        </form>

        {#each area.items as item, index (index)}
          <div
            class="grid grid-cols-[minmax(0,1fr)_auto_auto] items-center gap-2 border-t border-hairline py-2.5 text-sm"
          >
            {#if editing === index}
              <!-- svelte-ignore a11y_autofocus -->
              <input
                bind:value={editValue}
                autofocus
                onkeydown={(event) => {
                  if (event.key === 'Enter') commitEdit()
                  if (event.key === 'Escape') editing = null
                }}
                class={[fieldInput, 'border-accent bg-white']}
              />
            {:else}
              <span class="min-w-0 font-medium wrap-anywhere">{item}</span>
            {/if}
            <button
              type="button"
              onclick={() => {
                if (editing === index) return commitEdit()
                editing = index
                editValue = item
              }}
              class="cursor-pointer rounded-full bg-canvas px-3 py-1 text-[12.5px] font-semibold text-body"
            >
              {editing === index ? 'Save' : 'Edit'}
            </button>
            <button
              type="button"
              onclick={() => {
                area.items.splice(index, 1)
                editing = null
              }}
              class={removeButton}
            >
              Remove
            </button>
          </div>
        {/each}
      {/if}
    </div>
  {/if}
</div>
