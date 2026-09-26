<script lang="ts">
  import { toneDot, type Tone } from '@/lib/tones'

  let {
    tone,
    pulse = false,
    class: extra = '',
  }: { tone: Tone; pulse?: boolean; class?: string } = $props()
</script>

<span
  class={[
    'inline-block size-1.5 shrink-0 rounded-full',
    toneDot[tone],
    pulse && 'animate-pulse-dot',
    extra,
  ]}
></span>
