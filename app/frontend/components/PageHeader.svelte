<script lang="ts">
  import type { Snippet } from 'svelte'

  let {
    eyebrow,
    title,
    description,
    aside,
  }: { eyebrow: string; title: string; description?: string; aside?: Snippet } = $props()
</script>

<svelte:head>
  <title>{eyebrow} · Headquarter</title>
</svelte:head>

<div class="mb-6 flex flex-wrap items-end justify-between gap-4">
  <div>
    <div class="mb-1.5 text-[13px] font-semibold text-muted">{eyebrow}</div>
    <h1 class="text-[clamp(28px,4vw,38px)] leading-[1.1] font-bold tracking-[-0.025em] text-pretty">
      {title}
    </h1>
    {#if description}
      <p class="mt-2 max-w-[60ch] text-sm leading-normal text-pretty text-muted">{description}</p>
    {/if}
  </div>
  {@render aside?.()}
</div>
