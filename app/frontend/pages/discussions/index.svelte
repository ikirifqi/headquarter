<script lang="ts">
  import { Link } from '@inertiajs/svelte'
  import PageHeader from '@/components/PageHeader.svelte'
  import { formatDate } from '@/lib/format'
  import type { Meeting, MeetingListItem } from '@/types/headquarter'

  let { meetings, meeting }: { meetings: MeetingListItem[]; meeting: Meeting } = $props()

  // Remembers which meeting the transcript was opened for, so it closes when switching meetings
  let transcriptFor = $state<number | null>(null)
  const showTranscript = $derived(transcriptFor === meeting.id)

  const label = 'mb-2 text-xs font-bold tracking-[.04em] text-muted uppercase'
</script>

<PageHeader eyebrow="Discussions" title="Meeting notes" />

<div class="flex flex-wrap items-start gap-4">
  <div class="flex max-w-[320px] flex-[1_1_240px] flex-col gap-1.5 max-sm:max-w-none">
    {#each meetings as item (item.id)}
      <Link
        href={`/discussions/${item.id}`}
        preserveScroll
        class={[
          'rounded-[14px] border px-4 py-3.5 text-left hover:border-accent-ring',
          item.id === meeting.id ? 'border-rule bg-white' : 'border-transparent',
        ]}
      >
        <div class="text-xs font-semibold text-muted">
          {formatDate(item.date)} · {item.project_name}
        </div>
        <div class="mt-1 text-[14.5px] leading-[1.35] font-semibold text-pretty text-ink">
          {item.title}
        </div>
      </Link>
    {/each}
  </div>

  <article class="min-w-0 flex-[3_1_320px] rounded-[20px] border border-rule bg-white p-7">
    <div class="text-[12.5px] font-semibold text-muted">
      {formatDate(meeting.date)} · {meeting.duration} · {meeting.attendees}
    </div>
    <h2 class="mt-1.5 mb-5 text-[26px] leading-[1.2] font-bold tracking-[-0.02em] text-pretty">
      {meeting.title}
    </h2>

    <div class={label}>Summary</div>
    <p class="mb-6 max-w-[68ch] text-[15.5px] leading-[1.65] text-pretty">{meeting.summary}</p>

    <div class="mb-6 grid grid-cols-[repeat(auto-fit,minmax(240px,1fr))] gap-4">
      <div class="rounded-[14px] bg-canvas p-4">
        <div class={label}>Decisions</div>
        <ul class="list-disc pl-[18px] text-sm leading-relaxed">
          {#each meeting.decisions as decision (decision)}
            <li>{decision}</li>
          {/each}
        </ul>
      </div>
      <div class="rounded-[14px] bg-canvas p-4">
        <div class={label}>Action items</div>
        <div class="flex flex-col gap-2 text-sm leading-normal">
          {#each meeting.actions as action (action.text)}
            <div class="grid grid-cols-[minmax(0,1fr)_auto] gap-3">
              <span>{action.text}</span>
              <span class="text-xs font-bold whitespace-nowrap text-accent">{action.owner}</span>
            </div>
          {/each}
        </div>
      </div>
    </div>

    <button
      type="button"
      onclick={() => (transcriptFor = showTranscript ? null : meeting.id)}
      class="cursor-pointer rounded-full border border-rule bg-canvas px-3.5 py-1.5 text-[13px] font-semibold text-body"
    >
      {showTranscript ? 'Hide transcript' : 'Show transcript'}
    </button>

    {#if showTranscript}
      <div class="mt-5 flex animate-fade-in flex-col gap-3.5 border-t border-hairline pt-5">
        {#each meeting.transcript as line (line.at + line.who)}
          <div class="grid grid-cols-[110px_minmax(0,1fr)] gap-3 text-sm leading-[1.55]">
            <div>
              <div class="font-semibold">{line.who}</div>
              <div class="text-[11.5px] text-faint tabular-nums">{line.at}</div>
            </div>
            <div class="text-body">{line.text}</div>
          </div>
        {/each}
      </div>
    {/if}
  </article>
</div>
