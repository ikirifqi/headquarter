<script lang="ts">
  import ProjectHeader from '@/components/ProjectHeader.svelte'
  import { formatDate } from '@/lib/format'
  import { taskStyle } from '@/lib/tones'
  import type { Epic, ProjectOverview, ProjectTab, Task } from '@/types/headquarter'

  let {
    project,
    projects,
    epics,
  }: { project: ProjectOverview; projects: ProjectTab[]; epics: Epic[] } = $props()

  let groupByEpic = $state(true)

  const tasks = $derived(epics.flatMap((epic) => epic.tasks))
  const doneCount = (list: Task[]) => list.filter((task) => task.status === 'done').length
  const donePercent = $derived(
    tasks.length ? Math.round((doneCount(tasks) / tasks.length) * 100) : 0,
  )

  const groups = $derived(
    groupByEpic
      ? epics.map((epic) => ({
          name: epic.name,
          count: `${doneCount(epic.tasks)}/${epic.tasks.length}`,
          tasks: epic.tasks,
        }))
      : [
          {
            name: null,
            count: null,
            tasks: [...tasks].sort((a, b) => taskStyle[a.status].order - taskStyle[b.status].order),
          },
        ],
  )
</script>

<ProjectHeader eyebrow="Progression" section="progress" {project} {projects} />

<div class="mb-5 grid grid-cols-[repeat(auto-fit,minmax(230px,1fr))] gap-3">
  <div class="rounded-2xl border border-rule bg-white p-[18px]">
    <div class="text-xs font-semibold text-muted">Working on</div>
    <div class="mt-1.5 text-lg font-bold tracking-[-0.01em]">{project.current_epic}</div>
  </div>
  <div class="rounded-2xl border border-rule bg-white p-[18px]">
    <div class="text-xs font-semibold text-muted">Next deliverable</div>
    <div class="mt-1.5 text-lg leading-[1.3] font-bold tracking-[-0.01em]">
      {project.next_deliverable}
    </div>
    <div class="mt-1 text-[13px] font-semibold text-accent">
      {formatDate(project.next_date, 'weekday')}
    </div>
  </div>
  <div class="rounded-2xl border border-rule bg-white p-[18px]">
    <div class="text-xs font-semibold text-muted">Tasks done</div>
    <div class="mt-1.5 text-lg font-bold tracking-[-0.01em]">
      {doneCount(tasks)} of {tasks.length}
    </div>
    <div class="mt-3 h-1.5 overflow-hidden rounded-full bg-track">
      <div class="h-full rounded-full bg-up" style:width="{donePercent}%"></div>
    </div>
  </div>
</div>

<section class="rounded-[20px] border border-rule bg-white px-[22px] pt-1.5 pb-3">
  <div class="flex flex-wrap items-center justify-between gap-3 pt-3.5 pb-2">
    <h2 class="text-base font-bold">Tasks</h2>
    <button
      type="button"
      onclick={() => (groupByEpic = !groupByEpic)}
      class="cursor-pointer rounded-full border border-rule bg-canvas px-3 py-1.5 text-[12.5px] font-semibold text-body"
    >
      {groupByEpic ? 'Grouped by epic' : 'Flat list'}
    </button>
  </div>

  {#each groups as group (group.name)}
    <div>
      {#if group.name}
        <div
          class="flex justify-between pt-4 pb-1.5 text-xs font-bold tracking-[.04em] text-muted uppercase"
        >
          {group.name}<span class="tabular-nums">{group.count}</span>
        </div>
      {/if}
      {#each group.tasks as task (task.id)}
        {@const style = taskStyle[task.status]}
        <div
          class="grid grid-cols-[16px_auto_minmax(0,1fr)_auto] items-center gap-3 border-t border-hairline py-2.5 text-sm"
        >
          <span class={['inline-block size-3.5 rounded-full border-2', style.ring]}></span>
          <span
            class="rounded-md bg-canvas px-1.5 py-0.5 text-[11px] font-bold text-muted tabular-nums"
          >
            {task.id}
          </span>
          <div class="min-w-0">
            <span
              class={[
                'font-medium',
                task.status === 'done' ? 'text-muted line-through' : 'text-ink',
              ]}
            >
              {task.title}
            </span>
            <span class="ml-1.5 text-xs text-faint">{task.owner ?? '—'}</span>
          </div>
          <span class={['text-xs font-bold', style.text]}>{style.label}</span>
        </div>
      {/each}
    </div>
  {/each}
</section>
