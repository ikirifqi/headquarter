<script lang="ts" generics="T extends string">
  import { Link } from '@inertiajs/svelte'

  type Item = { value: T; label: string; href?: string }

  let {
    items,
    active,
    onselect,
    size = 'md',
    class: extra = '',
  }: {
    items: Item[]
    active: T
    onselect?: (value: T) => void
    size?: 'sm' | 'md'
    class?: string
  } = $props()

  const itemClass = (item: Item) => [
    'cursor-pointer rounded-full font-semibold whitespace-nowrap transition-colors',
    size === 'sm' ? 'px-3 py-1 text-xs' : 'px-3.5 py-1.5 text-[13px]',
    item.value === active ? 'bg-ink text-white' : 'text-muted hover:text-ink',
  ]
</script>

<div
  class={[
    'flex w-fit max-w-full gap-0.5 overflow-x-auto rounded-full border border-rule bg-white p-[3px]',
    extra,
  ]}
>
  {#each items as item (item.value)}
    {#if item.href}
      <Link href={item.href} preserveScroll class={itemClass(item)}>{item.label}</Link>
    {:else}
      <button type="button" class={itemClass(item)} onclick={() => onselect?.(item.value)}>
        {item.label}
      </button>
    {/if}
  {/each}
</div>
