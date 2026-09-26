<script lang="ts">
  import { untrack } from 'svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import type { Integration } from '@/types/headquarter'

  let { integrations: initial }: { integrations: Integration[] } = $props()

  let integrations = $state(untrack(() => $state.snapshot(initial)))

  function toggle(integration: Integration) {
    integration.connected = !integration.connected
    if (!integration.connected) integration.schedule = 'not connected'
    else if (integration.schedule === 'not connected') integration.schedule = 'connected just now'
  }
</script>

<p class="mb-[18px] max-w-[70ch] text-sm leading-[1.55] text-pretty text-muted">
  Each page reads from one source. Connect an API or an MCP server; Headquarter polls it on the
  interval shown and never writes back.
</p>

<div class="grid grid-cols-[repeat(auto-fit,minmax(280px,1fr))] gap-3">
  {#each integrations as integration (integration.area)}
    <div class="flex flex-col gap-3 rounded-[18px] border border-rule bg-white p-5">
      <div class="flex items-center justify-between gap-2">
        <div class="text-base font-bold tracking-[-0.01em]">{integration.area}</div>
        <span
          class={[
            'inline-flex items-center gap-1.5 text-xs font-bold',
            integration.connected ? 'text-up' : 'text-muted',
          ]}
        >
          <StatusDot tone={integration.connected ? 'up' : 'muted'} />
          {integration.connected ? 'Connected' : 'Not connected'}
        </span>
      </div>
      <div class="text-[13px] text-muted">{integration.source}</div>
      <div class="rounded-[10px] bg-canvas px-3 py-2 font-mono text-xs wrap-anywhere text-body">
        {integration.endpoint}
      </div>
      <div class="flex items-center justify-between gap-2 text-xs font-medium text-muted">
        <span>{integration.schedule}</span>
        <button
          type="button"
          onclick={() => toggle(integration)}
          class={[
            'cursor-pointer rounded-full border border-rule px-3 py-1.5 text-xs font-semibold',
            integration.connected ? 'bg-white text-muted' : 'bg-ink text-white',
          ]}
        >
          {integration.connected ? 'Disconnect' : 'Connect'}
        </button>
      </div>
    </div>
  {/each}
</div>
