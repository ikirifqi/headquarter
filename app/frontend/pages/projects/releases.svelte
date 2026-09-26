<script lang="ts">
  import ProjectHeader from '@/components/ProjectHeader.svelte'
  import Badge from '@/components/Badge.svelte'
  import { capitalize, formatDate } from '@/lib/format'
  import { changeTone, channelTone } from '@/lib/tones'
  import type { ChangeKind, ProjectOverview, ProjectTab, Release } from '@/types/headquarter'

  let {
    project,
    projects,
    releases,
  }: { project: ProjectOverview; projects: ProjectTab[]; releases: Release[] } = $props()

  const changeKinds: ChangeKind[] = ['added', 'changed', 'fixed']
</script>

<ProjectHeader eyebrow="Releases" section="releases" {project} {projects} />

<div class="flex flex-col gap-3.5">
  {#each releases as release (release.version)}
    <article
      class="grid grid-cols-1 gap-x-6 gap-y-3 rounded-[20px] border border-rule bg-white p-6 sm:grid-cols-[minmax(120px,170px)_minmax(0,1fr)]"
    >
      <div>
        <div class="text-2xl font-bold tracking-[-0.02em] tabular-nums">{release.version}</div>
        <div class="mt-1 mb-2.5 text-[12.5px] text-muted">{formatDate(release.date)}</div>
        <Badge tone={channelTone[release.channel]}>{capitalize(release.channel)}</Badge>
      </div>
      <div>
        <div class="mb-1.5 text-[17px] font-bold tracking-[-0.01em]">{release.title}</div>
        <p class="mb-4 max-w-[70ch] text-sm leading-[1.55] text-pretty text-body">
          {release.summary}
        </p>
        <div class="flex flex-col gap-2.5">
          {#each changeKinds.filter((kind) => release.changes[kind]?.length) as kind (kind)}
            <div class="grid grid-cols-[72px_minmax(0,1fr)] gap-3">
              <span class="h-fit text-center">
                <Badge tone={changeTone[kind]}>{capitalize(kind)}</Badge>
              </span>
              <ul class="list-disc pl-4 text-sm leading-relaxed">
                {#each release.changes[kind] ?? [] as item (item)}
                  <li>{item}</li>
                {/each}
              </ul>
            </div>
          {/each}
        </div>
      </div>
    </article>
  {/each}
</div>
