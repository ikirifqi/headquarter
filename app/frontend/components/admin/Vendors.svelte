<script lang="ts">
  import { untrack } from 'svelte'
  import { createCopier } from '@/lib/clipboard.svelte'
  import { formatDate } from '@/lib/format'
  import {
    darkButton,
    fieldInput,
    fieldLabel,
    ghostButton,
    primaryButton,
    removeButton,
  } from '@/lib/ui'
  import type { Vendor } from '@/types/headquarter'

  let { vendors: initial, owner }: { vendors: Vendor[]; owner: string } = $props()

  let vendors = $state(untrack(() => $state.snapshot(initial)))
  let revealed = $state<Record<number, boolean>>({})
  let formOpen = $state(false)

  const blank = { name: '', use: '', login: '', password: '', owner: '', two_factor: '', plan: '' }
  let draft = $state({ ...blank })
  const clipboard = createCopier()

  const fields: { key: keyof typeof blank; label: string; hint?: string; placeholder: string }[] = [
    { key: 'name', label: 'Vendor', placeholder: 'e.g. Cloudflare' },
    { key: 'use', label: 'Used for', placeholder: 'DNS and CDN' },
    { key: 'login', label: 'Login', placeholder: 'ops@halden.ai' },
    { key: 'password', label: 'Password', hint: '(leave blank for SSO)', placeholder: '••••••••' },
    { key: 'owner', label: 'Owner', placeholder: 'Dev' },
    { key: 'two_factor', label: '2FA', placeholder: 'Authenticator · Dev' },
    { key: 'plan', label: 'Plan', placeholder: 'Pro · $20/mo' },
  ]

  function addVendor() {
    const value = Object.fromEntries(
      Object.entries(draft).map(([key, text]) => [key, text.trim()]),
    ) as typeof blank
    if (!value.name || !value.login) return
    vendors.push({
      id: Math.max(0, ...vendors.map((vendor) => vendor.id)) + 1,
      name: value.name,
      use: value.use,
      login: value.login,
      password: value.password || undefined,
      sso: value.password ? undefined : 'SSO',
      owner: value.owner || owner,
      two_factor: value.two_factor || '—',
      plan: value.plan || '—',
      rotated_on: value.password ? new Date().toISOString().slice(0, 10) : undefined,
    })
    draft = { ...blank }
    formOpen = false
  }

  const columns =
    'grid grid-cols-[minmax(170px,1.3fr)_minmax(190px,1.3fr)_minmax(210px,1.4fr)_minmax(120px,.9fr)_60px] gap-3'
  const pill =
    'shrink-0 cursor-pointer rounded-full px-2.5 py-1 text-[11.5px] font-semibold text-body'
</script>

<div class="mb-[18px] flex flex-wrap items-start justify-between gap-4">
  <p class="max-w-[64ch] text-sm leading-[1.55] text-pretty text-muted">
    Every third-party service we pay for, who owns it, and how to get in. Passwords stay hidden
    until revealed and are only visible to admins.
  </p>
  <button type="button" onclick={() => (formOpen = !formOpen)} class={darkButton}>
    + Add vendor
  </button>
</div>

{#if formOpen}
  <form
    class="mb-4 flex animate-fade-in flex-col gap-3.5 rounded-[18px] border-[1.5px] border-accent bg-white p-[18px]"
    onsubmit={(event) => {
      event.preventDefault()
      addVendor()
    }}
  >
    <div class="grid grid-cols-[repeat(auto-fit,minmax(180px,1fr))] gap-3">
      {#each fields as field (field.key)}
        <label class={fieldLabel}>
          <span>{field.label} <span class="font-medium text-faint">{field.hint ?? ''}</span></span>
          <input
            type={field.key === 'password' ? 'password' : 'text'}
            bind:value={draft[field.key]}
            placeholder={field.placeholder}
            class={fieldInput}
          />
        </label>
      {/each}
    </div>
    <div class="flex justify-end gap-1.5">
      <button type="button" onclick={() => (formOpen = false)} class={ghostButton}>Cancel</button>
      <button class={primaryButton}>Save vendor</button>
    </div>
  </form>
{/if}

<div class="overflow-x-auto rounded-[20px] border border-rule bg-white px-[22px] py-1.5">
  <div class="min-w-[760px]">
    <div
      class={[
        columns,
        'pt-3.5 pb-2.5 text-[11.5px] font-bold tracking-[.04em] text-muted uppercase',
      ]}
    >
      <div>Vendor</div>
      <div>Login</div>
      <div>Password</div>
      <div>Owner · 2FA</div>
      <div></div>
    </div>
    {#each vendors as vendor (vendor.id)}
      {@const shown = revealed[vendor.id]}
      <div class={[columns, 'items-center border-t border-hairline py-3 text-sm']}>
        <div class="min-w-0">
          <div class="font-semibold">{vendor.name}</div>
          <div class="text-[12.5px] leading-snug text-muted">{vendor.use}</div>
          <div class="mt-0.5 text-[11.5px] text-faint">{vendor.plan}</div>
        </div>
        <div class="flex min-w-0 items-center gap-1.5">
          <span class="min-w-0 truncate text-[13.5px] font-medium">{vendor.login}</span>
          <button
            type="button"
            onclick={() => clipboard.copy(`login-${vendor.id}`, vendor.login)}
            class={[pill, 'bg-canvas']}
          >
            {clipboard.copied === `login-${vendor.id}` ? 'Copied' : 'Copy'}
          </button>
        </div>
        <div class="min-w-0">
          {#if vendor.password}
            <div class="flex items-center gap-1.5">
              <span
                class={[
                  'min-w-0 flex-1 rounded-lg bg-canvas px-2.5 py-1.5 text-[13px] leading-snug tracking-[.04em] wrap-anywhere',
                  shown && 'font-mono',
                ]}
              >
                {shown ? vendor.password : '••••••••••••'}
              </span>
              <button
                type="button"
                onclick={() => (revealed[vendor.id] = !shown)}
                class={[pill, 'border border-rule bg-white']}
              >
                {shown ? 'Hide' : 'Reveal'}
              </button>
              <button
                type="button"
                onclick={() => clipboard.copy(`password-${vendor.id}`, vendor.password ?? '')}
                class={[pill, 'bg-canvas']}
              >
                {clipboard.copied === `password-${vendor.id}` ? 'Copied' : 'Copy'}
              </button>
            </div>
            <div class="mt-1 text-[11.5px] text-faint">
              Rotated {vendor.rotated_on ? formatDate(vendor.rotated_on) : '—'}
            </div>
          {:else}
            <span
              class="inline-flex items-center rounded-full bg-info-soft px-2.5 py-1 text-xs font-bold text-info"
            >
              {vendor.sso ?? 'SSO'}
            </span>
          {/if}
        </div>
        <div>
          <div class="text-[13.5px] font-semibold">{vendor.owner}</div>
          <div class="text-xs leading-snug text-muted">{vendor.two_factor}</div>
        </div>
        <button
          type="button"
          onclick={() => (vendors = vendors.filter((v) => v.id !== vendor.id))}
          class={[removeButton, 'justify-self-end']}
        >
          Remove
        </button>
      </div>
    {/each}
  </div>
</div>
