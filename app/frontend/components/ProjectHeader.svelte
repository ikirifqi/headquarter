<script lang="ts">
  import PageHeader from '@/components/PageHeader.svelte'
  import Segmented from '@/components/Segmented.svelte'
  import type { ProjectOverview, ProjectTab } from '@/types/headquarter'

  let {
    eyebrow,
    section,
    project,
    projects,
  }: {
    eyebrow: string
    section: 'roadmap' | 'progress' | 'releases'
    project: ProjectOverview
    projects: ProjectTab[]
  } = $props()

  const tabs = $derived(
    projects.map((p) => ({ value: p.id, label: p.name, href: `/${section}/${p.id}` })),
  )
</script>

<PageHeader {eyebrow} title={project.name} description={project.description}>
  {#snippet aside()}
    <Segmented items={tabs} active={project.id} />
  {/snippet}
</PageHeader>
