<script lang="ts">
  import { Link, page } from '@inertiajs/svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import Badge from '@/components/Badge.svelte'
  import { formatDate, money } from '@/lib/format'
  import {
    incidentTone,
    serviceLabel,
    serviceTone,
    stageTone,
    toneDot,
    toneText,
  } from '@/lib/tones'
  import type {
    DueSoon,
    HealthOverview,
    Incident,
    LatestRelease,
    Meeting,
    ProjectCard,
    Service,
  } from '@/types/headquarter'

  let {
    services,
    health,
    open_incident: openIncident,
    due_soon: dueSoon,
    project_cards: projectCards,
    latest_release: latestRelease,
    latest_meeting: latestMeeting,
    idea_stages: ideaStages,
  }: {
    services: Pick<Service, 'name' | 'status'>[]
    health: HealthOverview
    open_incident: Incident | null
    due_soon: DueSoon
    project_cards: ProjectCard[]
    latest_release: LatestRelease
    latest_meeting: Pick<Meeting, 'id' | 'date' | 'title' | 'summary' | 'attendees'>
    idea_stages: { id: string; name: string; count: number }[]
  } = $props()

  const user = $derived(page.props.current_user)
  const organization = $derived(page.props.organization)
  const ideaCount = $derived(ideaStages.reduce((sum, stage) => sum + stage.count, 0))
  const healthTone = $derived(health.degraded ? 'warn' : 'up')
  const healthHeadline = $derived(
    health.degraded
      ? `${health.degraded} service${health.degraded > 1 ? 's' : ''} degraded, everything else running`
      : 'All systems operational',
  )

  const card =
    'flex flex-col gap-3.5 rounded-[20px] border border-rule bg-white p-[22px] text-left transition-shadow hover:border-accent-ring hover:shadow-[0_8px_24px_rgba(23,23,26,.06)]'
</script>

<svelte:head>
  <title>Dashboard · Headquarter</title>
</svelte:head>

<div class="mb-7 flex flex-wrap items-end justify-between gap-4">
  <div>
    <div class="mb-1.5 text-[13px] font-semibold text-muted">
      {formatDate(organization.today, 'long')}
    </div>
    <h1 class="text-[clamp(28px,4vw,38px)] leading-[1.1] font-bold tracking-[-0.025em] text-pretty">
      {user ? `Good morning, ${user.first_name}` : `${organization.name} at a glance`}
    </h1>
  </div>
  <div
    class={[
      'inline-flex items-center gap-2 rounded-full px-3.5 py-2 text-[13px] font-semibold',
      healthTone === 'up' ? 'bg-up-soft text-up' : 'bg-warn-soft text-warn',
    ]}
  >
    <StatusDot tone={healthTone} pulse class="size-2" />
    {healthHeadline}
  </div>
</div>

<div class="grid grid-cols-[repeat(auto-fit,minmax(280px,1fr))] gap-4">
  <Link href="/health" class={card}>
    <div class="flex items-center justify-between">
      <span class="text-[13px] font-semibold text-muted">Systems</span>
      <span class="text-xs font-semibold text-accent">Health →</span>
    </div>
    <div class="flex flex-col gap-2.5">
      {#each services as service (service.name)}
        <div class="flex items-center justify-between gap-2.5 text-sm">
          <span class="font-medium">{service.name}</span>
          <span
            class={[
              'inline-flex items-center gap-1.5 text-xs font-semibold',
              toneText[serviceTone[service.status]],
            ]}
          >
            <StatusDot tone={serviceTone[service.status]} />
            {serviceLabel[service.status]}
          </span>
        </div>
      {/each}
    </div>
  </Link>

  {#if openIncident}
    <Link href="/health" class={card}>
      <div class="flex items-center justify-between">
        <span class="text-[13px] font-semibold text-muted">Open incident</span>
        <Badge tone={incidentTone(openIncident.state)}>
          <span class="capitalize">{openIncident.state}</span>
        </Badge>
      </div>
      <div class="text-lg leading-[1.3] font-bold tracking-[-0.01em] text-pretty">
        {openIncident.title}
      </div>
      <div class="text-[13px] leading-normal text-muted">{openIncident.updates[0]?.text}</div>
      <div class="mt-auto text-xs text-faint">
        {formatDate(openIncident.date)} · {openIncident.duration}
      </div>
    </Link>
  {/if}

  <Link
    href="/billing"
    class="flex flex-col gap-3.5 rounded-[20px] border border-ink bg-ink p-[22px] text-left text-white hover:bg-black"
  >
    <div class="flex items-center justify-between">
      <span class="text-[13px] font-semibold text-faint">Due in the next 30 days</span>
      <span class="text-xs font-semibold text-accent-ring">Billing →</span>
    </div>
    <div class="text-[40px] leading-none font-bold tracking-[-0.03em] tabular-nums">
      {money(dueSoon.total)}
    </div>
    <div class="flex flex-col gap-2 border-t border-white/12 pt-3">
      {#each dueSoon.next as bill (bill.id)}
        <div class="flex justify-between gap-2.5 text-[13px]">
          <span class="text-zinc-300">
            <span class="text-faint tabular-nums">{formatDate(bill.date, 'dayMonth')}</span>
            {bill.platform}
          </span>
          <span class="font-semibold tabular-nums">{money(bill.amount)}</span>
        </div>
      {/each}
    </div>
  </Link>

  {#each projectCards as project (project.id)}
    <Link href={`/progress/${project.id}`} class={card}>
      <div class="flex items-center justify-between">
        <span class="text-base font-bold tracking-[-0.01em]">{project.name}</span>
        <span class="text-xs font-semibold text-muted">{project.done_percent}% of tasks</span>
      </div>
      <div class="h-1.5 overflow-hidden rounded-full bg-track">
        <div class="h-full rounded-full bg-accent" style:width="{project.done_percent}%"></div>
      </div>
      <div>
        <div class="mb-1 text-xs font-semibold text-muted">Next deliverable</div>
        <div class="text-[15px] leading-[1.35] font-semibold text-pretty">
          {project.next_deliverable}
        </div>
        <div class="mt-1 text-[13px] font-semibold text-accent">
          {formatDate(project.next_date, 'weekday')}
        </div>
      </div>
      <div class="mt-auto text-[13px] text-muted">
        Working on <span class="font-semibold text-ink">{project.current_epic}</span>
      </div>
    </Link>
  {/each}

  <Link href={`/releases/${latestRelease.project_id}`} class={card}>
    <div class="flex items-center justify-between">
      <span class="text-[13px] font-semibold text-muted">Latest release</span>
      <span class="text-xs font-semibold text-accent">Releases →</span>
    </div>
    <div class="flex items-baseline gap-2.5">
      <span class="text-[26px] font-bold tracking-[-0.02em] tabular-nums">
        {latestRelease.version}
      </span>
      <span class="text-[13px] text-muted">
        {latestRelease.project_name} · {formatDate(latestRelease.date)}
      </span>
    </div>
    <div class="text-[15px] font-semibold">{latestRelease.title}</div>
    <div class="text-[13px] leading-normal text-pretty text-muted">{latestRelease.summary}</div>
  </Link>

  <Link href={`/discussions/${latestMeeting.id}`} class={card}>
    <div class="flex items-center justify-between">
      <span class="text-[13px] font-semibold text-muted">Latest discussion</span>
      <span class="text-xs font-semibold text-accent">Discussions →</span>
    </div>
    <div class="text-[17px] leading-[1.3] font-bold tracking-[-0.01em]">{latestMeeting.title}</div>
    <div class="line-clamp-4 text-[13px] leading-[1.55] text-pretty text-muted">
      {latestMeeting.summary}
    </div>
    <div class="mt-auto text-xs text-faint">
      {formatDate(latestMeeting.date)} · {latestMeeting.attendees}
    </div>
  </Link>

  <Link href="/ideas" class={card}>
    <div class="flex items-center justify-between">
      <span class="text-[13px] font-semibold text-muted">Ideas</span>
      <span class="text-xs font-semibold text-accent">Board →</span>
    </div>
    <div class="text-[40px] leading-none font-bold tracking-[-0.03em]">{ideaCount}</div>
    <div class="flex h-2 gap-0.5 overflow-hidden rounded-full">
      {#each ideaStages.filter((stage) => stage.count > 0) as stage (stage.id)}
        <div class={toneDot[stageTone(stage.id)]} style:flex={stage.count}></div>
      {/each}
    </div>
    <div class="flex flex-wrap gap-3">
      {#each ideaStages as stage (stage.id)}
        <span class="inline-flex items-center gap-1.5 text-xs text-muted">
          <StatusDot tone={stageTone(stage.id)} />
          {stage.name} <b class="text-ink">{stage.count}</b>
        </span>
      {/each}
    </div>
  </Link>
</div>
