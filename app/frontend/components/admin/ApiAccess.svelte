<script lang="ts">
  import { untrack } from 'svelte'
  import Segmented from '@/components/Segmented.svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import { createCopier } from '@/lib/clipboard.svelte'
  import { formatDate } from '@/lib/format'
  import {
    darkButton,
    fieldInput,
    fieldLabel,
    ghostButton,
    primaryButton,
    removeButton,
    panel,
  } from '@/lib/ui'
  import type { ApiAccess, ApiKey } from '@/types/headquarter'

  let { api, owner }: { api: ApiAccess; owner: string } = $props()

  const scopeLabels: Record<string, string> = {
    health: 'Health',
    billing: 'Billing',
    roadmap: 'Roadmap',
    progress: 'Progression',
    releases: 'Releases',
    discussions: 'Discussions',
    ideas: 'Ideas',
    vendors: 'Vendors (secrets)',
  }
  const defaultScopes = () => api.scopes.filter((scope) => scope !== 'vendors')

  let keys = $state(untrack(() => $state.snapshot(api.keys)))
  let formOpen = $state(false)
  let keyName = $state('')
  let keyScopes = $state(defaultScopes())
  let newKey = $state<{ name: string; secret: string } | null>(null)
  let mcpEnabled = $state(untrack(() => api.mcp_enabled))
  let client = $state<'claude' | 'cursor' | 'generic'>('claude')
  const clipboard = createCopier()

  const clients = [
    { value: 'claude' as const, label: 'Claude Desktop' },
    { value: 'cursor' as const, label: 'Cursor' },
    { value: 'generic' as const, label: 'Any MCP client' },
  ]

  const keyHint = $derived(newKey?.secret ?? 'hq_live_…')
  const snippet = $derived(
    client === 'generic'
      ? `URL: ${api.mcp_url}\nAuthorization: Bearer ${keyHint}\nTools: ${api.tools.map((tool) => tool.name).join(', ')}`
      : JSON.stringify(
          {
            mcpServers: {
              headquarter: { url: api.mcp_url, headers: { Authorization: `Bearer ${keyHint}` } },
            },
          },
          null,
          2,
        ),
  )

  const scopeSummary = (key: ApiKey) =>
    key.scopes.length === api.scopes.length
      ? 'All pages'
      : `${key.scopes.length} of ${api.scopes.length} pages`

  function toggleScope(scope: string) {
    keyScopes = keyScopes.includes(scope)
      ? keyScopes.filter((s) => s !== scope)
      : [...keyScopes, scope]
  }

  function createKey() {
    const name = keyName.trim()
    if (!name || !keyScopes.length) return
    const bytes = crypto.getRandomValues(new Uint8Array(16))
    const secret = 'hq_live_' + Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('')
    keys.unshift({
      id: Math.max(0, ...keys.map((key) => key.id)) + 1,
      name,
      prefix: secret.slice(0, 12),
      scopes: [...keyScopes],
      created_on: new Date().toISOString().slice(0, 10),
      last_used: 'never',
      created_by: owner,
    })
    newKey = { name, secret }
    keyName = ''
    keyScopes = defaultScopes()
    formOpen = false
  }
</script>

<p class="mb-[18px] max-w-[70ch] text-sm leading-[1.55] text-pretty text-muted">
  Let other tools read Headquarter. API keys work for both the REST API and the MCP server; each key
  only sees the pages you grant it.
</p>

<div class="flex flex-col gap-4">
  <section class={[panel, 'p-[22px]']}>
    <div class="mb-1.5 flex flex-wrap items-center justify-between gap-3">
      <div>
        <h2 class="text-lg font-bold">API keys</h2>
        <div class="mt-1 text-[13px] text-muted">
          {keys.length} active · base URL <span class="font-mono text-body">{api.base_url}</span>
        </div>
      </div>
      <button
        type="button"
        onclick={() => {
          formOpen = !formOpen
          newKey = null
        }}
        class={darkButton}
      >
        + New key
      </button>
    </div>

    {#if newKey}
      <div
        class="mt-3 flex animate-fade-in flex-col gap-2 rounded-[14px] border border-green-200 bg-up-soft px-4 py-3.5"
      >
        <div class="text-[13.5px] font-bold text-up">
          Key created for “{newKey.name}”. Copy it now; it will not be shown again.
        </div>
        <div class="flex flex-wrap items-center gap-2">
          <code
            class="min-w-0 flex-1 rounded-[10px] bg-white px-3 py-2 font-mono text-[13px] wrap-anywhere"
          >
            {newKey.secret}
          </code>
          <button
            type="button"
            onclick={() => newKey && clipboard.copy('new-key', newKey.secret)}
            class="cursor-pointer rounded-full bg-up px-3.5 py-2 text-[12.5px] font-semibold text-white"
          >
            {clipboard.copied === 'new-key' ? 'Copied' : 'Copy key'}
          </button>
          <button
            type="button"
            onclick={() => (newKey = null)}
            class="cursor-pointer p-2 text-[12.5px] font-semibold text-up"
          >
            Done
          </button>
        </div>
      </div>
    {/if}

    {#if formOpen}
      <form
        class="mt-3 flex animate-fade-in flex-col gap-3.5 rounded-2xl border-[1.5px] border-accent p-4"
        onsubmit={(event) => {
          event.preventDefault()
          createKey()
        }}
      >
        <label class={fieldLabel}>
          <span>Name <span class="font-medium text-faint">(what will use this key)</span></span>
          <!-- svelte-ignore a11y_autofocus -->
          <input
            bind:value={keyName}
            autofocus
            placeholder="e.g. Notion sync, Claude Desktop · Mira"
            class={[fieldInput, 'max-w-[420px]']}
          />
        </label>
        <div class={fieldLabel}>
          Can read
          <div class="flex flex-wrap gap-1.5">
            {#each api.scopes as scope (scope)}
              {@const on = keyScopes.includes(scope)}
              <button
                type="button"
                aria-pressed={on}
                onclick={() => toggleScope(scope)}
                class={[
                  'cursor-pointer rounded-full border px-3 py-1.5 text-[12.5px] font-semibold whitespace-nowrap',
                  on ? 'border-ink bg-ink text-white' : 'border-rule bg-white text-muted',
                ]}
              >
                {scopeLabels[scope] ?? scope}
              </button>
            {/each}
          </div>
        </div>
        <div class="flex justify-end gap-1.5">
          <button type="button" onclick={() => (formOpen = false)} class={ghostButton}>
            Cancel
          </button>
          <button class={primaryButton}>Create key</button>
        </div>
      </form>
    {/if}

    <div class="mt-2.5">
      {#each keys as key (key.id)}
        <div
          class="grid grid-cols-1 items-center gap-x-4 gap-y-2.5 border-t border-hairline py-3 text-sm md:grid-cols-[minmax(160px,1.2fr)_minmax(170px,1fr)_minmax(180px,1.4fr)_auto]"
        >
          <div class="min-w-0">
            <div class="font-semibold">{key.name}</div>
            <div class="mt-0.5 text-xs text-muted">
              Created {formatDate(key.created_on)} by {key.created_by}
            </div>
          </div>
          <div class="min-w-0">
            <div class="truncate font-mono text-[12.5px] text-body">{key.prefix}••••••••••••</div>
            <div class="mt-0.5 text-xs text-faint">Last used {key.last_used}</div>
          </div>
          <div class="flex flex-wrap items-center gap-1">
            <span class="mr-1 text-xs font-semibold text-muted">{scopeSummary(key)}</span>
            {#each key.scopes as scope (scope)}
              <span
                class="rounded-full border border-rule bg-canvas px-2 py-0.5 text-[11px] font-semibold text-body"
              >
                {scopeLabels[scope] ?? scope}
              </span>
            {/each}
          </div>
          <button
            type="button"
            onclick={() => (keys = keys.filter((k) => k.id !== key.id))}
            class={[removeButton, 'justify-self-start md:justify-self-end']}
          >
            Revoke
          </button>
        </div>
      {/each}
    </div>
  </section>

  <section class={[panel, 'p-[22px]']}>
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div class="flex flex-wrap items-center gap-3">
        <h2 class="text-lg font-bold">MCP server</h2>
        <span
          class={[
            'inline-flex items-center gap-1.5 text-xs font-bold',
            mcpEnabled ? 'text-up' : 'text-muted',
          ]}
        >
          <StatusDot tone={mcpEnabled ? 'up' : 'muted'} />
          {mcpEnabled ? 'Enabled' : 'Disabled'}
        </span>
      </div>
      <button
        type="button"
        onclick={() => (mcpEnabled = !mcpEnabled)}
        class="cursor-pointer rounded-full border border-rule bg-white px-3.5 py-1.5 text-[12.5px] font-semibold text-body"
      >
        {mcpEnabled ? 'Disable' : 'Enable'}
      </button>
    </div>
    <p class="mt-1.5 mb-4 max-w-[70ch] text-[13.5px] leading-[1.55] text-pretty text-muted">
      Connect an AI assistant to Headquarter so it can answer questions like “what is due next
      month” or “what shipped in Atlas last week”. Authenticate with any API key above; the key’s
      pages decide which tools the assistant can call.
    </p>

    {#if mcpEnabled}
      <div class="flex flex-col gap-3.5">
        <div class={fieldLabel}>
          Server URL
          <div class="flex flex-wrap items-center gap-2">
            <code
              class="min-w-0 flex-1 rounded-[10px] bg-canvas px-3 py-2.5 font-mono text-[13px] font-normal wrap-anywhere text-ink"
            >
              {api.mcp_url}
            </code>
            <button
              type="button"
              onclick={() => clipboard.copy('mcp-url', api.mcp_url)}
              class="cursor-pointer rounded-full border border-rule bg-canvas px-3.5 py-1.5 text-xs font-semibold text-body"
            >
              {clipboard.copied === 'mcp-url' ? 'Copied' : 'Copy'}
            </button>
          </div>
        </div>

        <div class={fieldLabel}>
          <div class="flex flex-wrap items-center justify-between gap-2.5">
            Setup
            <Segmented
              items={clients}
              active={client}
              size="sm"
              onselect={(value) => (client = value)}
            />
          </div>
          <div class="relative">
            <pre
              class="overflow-x-auto rounded-[14px] bg-ink px-[18px] py-4 font-mono text-[12.5px] leading-relaxed font-normal wrap-anywhere whitespace-pre-wrap text-zinc-200">{snippet}</pre>
            <button
              type="button"
              onclick={() => clipboard.copy('mcp-snippet', snippet)}
              class="absolute top-2.5 right-2.5 cursor-pointer rounded-full bg-white/12 px-3 py-1 text-[11.5px] font-semibold text-white"
            >
              {clipboard.copied === 'mcp-snippet' ? 'Copied' : 'Copy config'}
            </button>
          </div>
        </div>

        <div class={fieldLabel}>
          Tools exposed
          <div class="grid grid-cols-[repeat(auto-fit,minmax(240px,1fr))] gap-2">
            {#each api.tools as tool (tool.name)}
              <div class="rounded-xl bg-canvas px-3 py-2.5">
                <div class="font-mono text-[12.5px] font-semibold text-accent">{tool.name}</div>
                <div class="mt-0.5 text-[12.5px] leading-snug font-medium text-muted">
                  {tool.description}
                </div>
              </div>
            {/each}
          </div>
        </div>
      </div>
    {/if}
  </section>
</div>
