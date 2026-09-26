<script lang="ts">
  import PageHeader from '@/components/PageHeader.svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import Badge from '@/components/Badge.svelte'
  import { formatDate } from '@/lib/format'
  import {
    incidentTone,
    queueTone,
    serviceBar,
    serviceLabel,
    serviceTone,
    toneBadge,
    toneText,
  } from '@/lib/tones'
  import type { HealthOverview, Incident, Queue, Service } from '@/types/headquarter'

  let {
    health,
    services,
    queues,
    incidents,
  }: { health: HealthOverview; services: Service[]; queues: Queue[]; incidents: Incident[] } =
    $props()

  const tone = $derived(health.degraded ? 'warn' : 'up')
  const headline = $derived(
    health.degraded
      ? `${health.degraded} service${health.degraded > 1 ? 's' : ''} degraded, everything else running`
      : 'All systems operational',
  )
  const openLabel = $derived(
    health.open_incidents
      ? `${health.open_incidents} incident${health.open_incidents > 1 ? 's' : ''} being monitored`
      : 'No open incidents',
  )
</script>

<div class="flex flex-col gap-7">
  <PageHeader eyebrow="Health" title={headline}>
    {#snippet aside()}
      <div
        class={[
          'inline-flex items-center gap-2 rounded-full px-3.5 py-2 text-[13px] font-semibold',
          tone === 'up' ? 'bg-up-soft text-up' : 'bg-warn-soft text-warn',
        ]}
      >
        <StatusDot {tone} pulse class="size-2" />
        {openLabel}
      </div>
    {/snippet}
  </PageHeader>

  <section class="rounded-[20px] border border-rule bg-white px-[22px] py-1.5">
    <div class="flex items-baseline justify-between pt-4 pb-2">
      <h2 class="text-base font-bold">Online services</h2>
      <span class="text-xs font-semibold text-muted">Last 7 days</span>
    </div>
    {#each services as service (service.name)}
      <div
        class="grid grid-cols-1 items-center gap-x-6 gap-y-3 border-t border-hairline py-3.5 md:grid-cols-[minmax(150px,1.2fr)_minmax(180px,2fr)_190px]"
      >
        <div>
          <div class="text-[14.5px] font-semibold">{service.name}</div>
          <div class="mt-0.5 text-[12.5px] text-muted">{service.description}</div>
        </div>
        <div class="flex h-[26px] gap-1">
          {#each service.history as day (day.date)}
            <div
              class={['flex-1 rounded-md', serviceBar[day.status]]}
              title={`${formatDate(day.date, 'dayMonth')} · ${serviceLabel[day.status].toLowerCase()}`}
            ></div>
          {/each}
        </div>
        <div class="flex min-w-[150px] items-center justify-end gap-3">
          <span class="text-xs text-muted tabular-nums">{service.uptime}</span>
          <span
            class={[
              'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-bold',
              toneBadge[serviceTone[service.status]],
            ]}
          >
            <StatusDot tone={serviceTone[service.status]} />
            {serviceLabel[service.status]}
          </span>
        </div>
      </div>
    {/each}
  </section>

  <section>
    <div class="mb-3 flex items-baseline justify-between px-1">
      <h2 class="text-base font-bold">Background jobs</h2>
      <span class="text-xs font-semibold text-muted">Heartbeat every 60s</span>
    </div>
    <div class="grid grid-cols-[repeat(auto-fit,minmax(230px,1fr))] gap-3">
      {#each queues as queue (queue.name)}
        <div class="rounded-2xl border border-rule bg-white p-[18px]">
          <div class="flex items-center justify-between gap-2">
            <div class="text-[14.5px] font-semibold">{queue.name}</div>
            <span
              class={[
                'inline-flex items-center gap-1.5 text-xs font-bold capitalize',
                toneText[queueTone[queue.status]],
              ]}
            >
              <StatusDot tone={queueTone[queue.status]} />
              {queue.status}
            </span>
          </div>
          <div class="mt-4 grid grid-cols-3 gap-2">
            {#each [[queue.depth, 'queued'], [queue.latency, 'avg wait'], [queue.last_beat, 'last beat']] as [value, label] (label)}
              <div>
                <div class="text-xl font-bold tracking-[-0.02em] tabular-nums">{value}</div>
                <div class="text-[11.5px] font-medium text-muted">{label}</div>
              </div>
            {/each}
          </div>
        </div>
      {/each}
    </div>
  </section>

  <section>
    <h2 class="mb-3 px-1 text-base font-bold">Incident log</h2>
    <div class="flex flex-col gap-3">
      {#each incidents as incident (incident.title)}
        <div
          class="grid grid-cols-1 gap-x-6 gap-y-3 rounded-[20px] border border-rule bg-white p-[22px] sm:grid-cols-[minmax(110px,150px)_minmax(0,1fr)]"
        >
          <div class="text-[12.5px] leading-relaxed text-muted tabular-nums">
            <div class="font-semibold text-ink">{formatDate(incident.date)}</div>
            {incident.duration}
          </div>
          <div>
            <div class="flex flex-wrap items-center gap-2.5">
              <div class="text-base font-bold tracking-[-0.01em]">{incident.title}</div>
              <Badge tone={incidentTone(incident.state)}>
                <span class="capitalize">{incident.state}</span>
              </Badge>
            </div>
            <div class="mt-1 text-[13px] text-muted">Affected: {incident.affected}</div>
            <div class="mt-4 flex flex-col gap-2.5 border-l-2 border-track pl-3.5">
              {#each incident.updates as update (update.time)}
                <div class="grid grid-cols-[44px_minmax(0,1fr)] gap-2.5 text-sm leading-normal">
                  <span class="pt-0.5 text-xs text-muted tabular-nums">{update.time}</span>
                  <span>
                    <b class="font-semibold">{update.label}</b>
                    <span class="text-body">{update.text}</span>
                  </span>
                </div>
              {/each}
            </div>
          </div>
        </div>
      {/each}
    </div>
  </section>
</div>
