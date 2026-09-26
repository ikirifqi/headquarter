<script lang="ts">
  import type { Snippet } from 'svelte'
  import { toneBadge, type Tone } from '@/lib/tones'

  let { tone, children }: { tone: Tone; children: Snippet } = $props()
</script>

<span
  class={['inline-block w-fit rounded-full px-2.5 py-0.5 text-[11px] font-bold', toneBadge[tone]]}
>
  {@render children()}
</span>
