<script lang="ts">
  import ProjectHeader from '@/components/ProjectHeader.svelte'
  import { formatDate } from '@/lib/format'
  import { milestoneStyle } from '@/lib/tones'
  import type { Milestone, ProjectOverview, ProjectTab } from '@/types/headquarter'

  let {
    project,
    projects,
    months,
    today_offset: todayOffset,
    milestones,
  }: {
    project: ProjectOverview
    projects: ProjectTab[]
    months: string[]
    today_offset: number
    milestones: Milestone[]
  } = $props()

  const legend = Object.values(milestoneStyle)
</script>

<ProjectHeader eyebrow="Roadmap" section="roadmap" {project} {projects} />

<section class="overflow-x-auto rounded-[20px] border border-rule bg-white p-[22px]">
  <div class="min-w-[680px]">
    <div class="grid grid-cols-[200px_minmax(0,1fr)] gap-x-4 pb-2.5">
      <div class="text-xs font-semibold text-muted">Milestone</div>
      <div class="grid" style:grid-template-columns="repeat({months.length}, 1fr)">
        {#each months as month (month)}
          <div class="text-xs font-semibold text-muted">{formatDate(month, 'month')}</div>
        {/each}
      </div>
    </div>

    <div class="grid grid-cols-[200px_minmax(0,1fr)] gap-x-4">
      {#each milestones as milestone (milestone.name)}
        {@const style = milestoneStyle[milestone.status]}
        <div class="border-t border-hairline py-3">
          <div class="text-sm font-semibold">{milestone.name}</div>
          <div class="mt-0.5 text-xs text-muted">
            {formatDate(milestone.starts_on, 'dayMonth')} – {formatDate(
              milestone.ends_on,
              'dayMonth',
            )}
          </div>
        </div>
        <div class="relative border-t border-hairline">
          <div
            class="absolute inset-0 grid"
            style:grid-template-columns="repeat({months.length}, 1fr)"
          >
            {#each months as month (month)}
              <div class="border-r border-hairline"></div>
            {/each}
          </div>
          <div
            class={[
              'absolute top-1/2 h-6 -translate-y-1/2 overflow-hidden rounded-lg',
              style.track,
            ]}
            style:left="{milestone.offset}%"
            style:width="{milestone.span}%"
          >
            <div class={['h-full', style.fill]} style:width="{milestone.progress}%"></div>
          </div>
          <div
            class={[
              'pointer-events-none absolute top-1/2 -translate-y-1/2 text-[11px] font-bold whitespace-nowrap',
              style.text,
            ]}
            style:left="calc({milestone.offset}% + 10px)"
          >
            {milestone.status === 'progress' ? `${milestone.progress}%` : style.label}
          </div>
          <div
            class="absolute inset-y-0 z-[1] w-0.5 -translate-x-1/2 bg-accent"
            style:left="{todayOffset}%"
          ></div>
        </div>
      {/each}
      <div></div>
      <div class="relative h-5">
        <span
          class="absolute top-1 -translate-x-1/2 rounded-full bg-accent px-1.5 py-0.5 text-[10px] font-bold text-white"
          style:left="{todayOffset}%"
        >
          Today
        </span>
      </div>
    </div>
  </div>
</section>

<div class="mt-3.5 flex flex-wrap gap-[18px] px-1.5 text-xs font-medium text-muted">
  {#each legend as item (item.label)}
    <span class="inline-flex items-center gap-1.5">
      <span class={['h-2 w-3.5 rounded', item.fill]}></span>
      {item.label}
    </span>
  {/each}
</div>
