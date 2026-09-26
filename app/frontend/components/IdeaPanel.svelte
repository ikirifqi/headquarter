<script lang="ts">
  import { Link, page } from '@inertiajs/svelte'
  import Segmented from '@/components/Segmented.svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import { canWrite, loginHref } from '@/lib/session'
  import { stageTone, toneBadge } from '@/lib/tones'
  import type { Idea, IdeaLink, LinkOption } from '@/types/headquarter'

  type LinkTab = 'projects' | 'discussions' | 'tickets'

  let {
    idea,
    stageName,
    linkOptions,
    onchange,
    onclose,
  }: {
    idea: Idea
    stageName: string
    linkOptions: Record<LinkTab, LinkOption[]>
    onchange: (idea: Idea) => void
    onclose: () => void
  } = $props()

  const writable = $derived(canWrite())
  const kindLabel = { project: 'Project', discussion: 'Discussion', ticket: 'Ticket' }
  const tabs: { value: LinkTab; label: string }[] = [
    { value: 'projects', label: 'Projects' },
    { value: 'discussions', label: 'Discussions' },
    { value: 'tickets', label: 'Tickets' },
  ]

  let pickerOpen = $state(false)
  let tab = $state<LinkTab>('projects')
  let ticketUrl = $state('')
  let comment = $state('')

  function addLink(link: IdeaLink) {
    if (!idea.links.some((existing) => existing.label === link.label)) {
      onchange({ ...idea, links: [...idea.links, link] })
    }
    pickerOpen = false
    ticketUrl = ''
  }

  function addTicketUrl() {
    const value = ticketUrl.trim()
    if (!value) return
    const ticketId = value.match(/([A-Z]{2,6}-\d+)/)?.[1]
    addLink({
      kind: 'ticket',
      label: ticketId ?? value.replace(/^https?:\/\//, ''),
      chip: ticketId ?? 'link',
      href: value.startsWith('http') ? value : `https://${value}`,
      external: true,
    })
  }

  function removeLink(index: number) {
    onchange({ ...idea, links: idea.links.filter((_, i) => i !== index) })
  }

  function addComment() {
    const text = comment.trim()
    const who = page.props.current_user?.first_name
    if (!text || !who) return
    onchange({ ...idea, comments: [...idea.comments, { who, when: 'now', text }] })
    comment = ''
  }

  const heading = 'text-xs font-bold tracking-[.04em] text-muted uppercase'
</script>

<svelte:window onkeydown={(event) => event.key === 'Escape' && onclose()} />

<button
  type="button"
  aria-label="Close"
  onclick={onclose}
  class="fixed inset-0 z-20 cursor-default bg-ink/40 backdrop-blur-[2px]"
></button>

<aside
  class="fixed inset-y-0 right-0 z-21 flex w-[min(500px,100vw)] animate-slide-in flex-col gap-[22px] overflow-y-auto bg-white px-7 pt-7 pb-10 shadow-[-16px_0_48px_rgba(23,23,26,.12)]"
>
  <div class="flex items-center justify-between gap-3">
    <span
      class={[
        'inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-bold',
        toneBadge[stageTone(idea.stage)],
      ]}
    >
      <StatusDot tone={stageTone(idea.stage)} class="size-[7px]" />
      {stageName}
    </span>
    <button
      type="button"
      onclick={onclose}
      class="size-[34px] cursor-pointer rounded-full bg-canvas text-lg leading-none text-muted"
    >
      ×
    </button>
  </div>

  <div>
    <h2 class="text-2xl leading-tight font-bold tracking-[-0.02em] text-pretty">{idea.title}</h2>
    <div class="mt-2 text-[12.5px] font-medium text-muted">
      Submitted by {idea.author} · {idea.age}
    </div>
  </div>
  <p class="text-[15px] leading-relaxed text-pretty text-body">{idea.body}</p>

  <div>
    <div class="mb-2 flex items-center justify-between">
      <div class={heading}>Linked</div>
      {#if writable}
        <button
          type="button"
          onclick={() => (pickerOpen = !pickerOpen)}
          class="cursor-pointer rounded-full bg-accent-soft px-3 py-1 text-xs font-bold text-accent"
        >
          {pickerOpen ? 'Close' : '+ Link'}
        </button>
      {/if}
    </div>

    <div class="flex flex-col gap-1.5">
      {#each idea.links as link, index (link.label)}
        {@const linkClass =
          'flex min-w-0 flex-1 items-center justify-between gap-2 rounded-xl border border-rule bg-canvas px-3.5 py-2.5 text-[13.5px] hover:border-accent'}
        <div class="flex items-center gap-1.5">
          {#if link.external}
            <a href={link.href} target="_blank" rel="noopener" class={linkClass}>
              <span class="truncate font-semibold">{link.label}</span>
              <span class="text-[11px] font-bold whitespace-nowrap text-muted">
                {kindLabel[link.kind]} ↗
              </span>
            </a>
          {:else}
            <Link href={link.href} class={linkClass}>
              <span class="truncate font-semibold">{link.label}</span>
              <span class="text-[11px] font-bold whitespace-nowrap text-muted">
                {kindLabel[link.kind]} →
              </span>
            </Link>
          {/if}
          {#if writable}
            <button
              type="button"
              title="Unlink"
              onclick={() => removeLink(index)}
              class="cursor-pointer px-1.5 py-1 text-base text-faint hover:text-down"
            >
              ×
            </button>
          {/if}
        </div>
      {:else}
        <div class="text-[13px] text-faint">Nothing linked yet.</div>
      {/each}
    </div>

    {#if pickerOpen}
      <div class="mt-2.5 flex flex-col gap-2.5 rounded-[14px] border border-rule bg-well p-3">
        <Segmented items={tabs} active={tab} size="sm" onselect={(value) => (tab = value)} />
        {#if tab === 'tickets'}
          <form
            class="grid grid-cols-[minmax(0,1fr)_auto] gap-1.5"
            onsubmit={(event) => {
              event.preventDefault()
              addTicketUrl()
            }}
          >
            <input
              bind:value={ticketUrl}
              placeholder="Paste a Linear / Jira / GitHub ticket URL"
              class="min-w-0 rounded-[10px] border-rule bg-white px-3 py-2 text-[13px] focus:border-accent focus:ring-0"
            />
            <button
              class="cursor-pointer rounded-[10px] bg-ink px-3 text-xs font-semibold text-white"
            >
              Link
            </button>
          </form>
        {/if}
        <div class="flex max-h-[220px] flex-col gap-1 overflow-y-auto">
          {#each linkOptions[tab] as option (option.label)}
            <button
              type="button"
              onclick={() => addLink(option)}
              class="flex cursor-pointer items-center justify-between gap-2 rounded-[10px] border border-rule bg-white px-3 py-2 text-left text-[13px] hover:border-accent"
            >
              <span class="truncate">{option.label}</span>
              <span class="text-[11px] font-semibold whitespace-nowrap text-faint"
                >{option.meta}</span
              >
            </button>
          {/each}
        </div>
      </div>
    {/if}
  </div>

  <div>
    <div class={[heading, 'mb-2.5']}>Comments</div>
    <div class="flex flex-col gap-3.5">
      {#each idea.comments as entry, index (index)}
        <div class="grid grid-cols-[32px_minmax(0,1fr)] gap-2.5 text-sm leading-normal">
          <span
            class="grid size-8 place-items-center rounded-full bg-accent-soft text-xs font-bold text-accent"
          >
            {entry.who[0]}
          </span>
          <div>
            <div class="flex items-baseline gap-2">
              <span class="font-semibold">{entry.who}</span>
              <span class="text-[11.5px] text-faint">{entry.when}</span>
            </div>
            <div class="mt-0.5 text-body">{entry.text}</div>
          </div>
        </div>
      {:else}
        <div class="text-[13px] text-faint">No follow-ups yet.</div>
      {/each}
    </div>

    {#if writable}
      <form
        class="mt-4 grid grid-cols-[minmax(0,1fr)_auto] gap-2"
        onsubmit={(event) => {
          event.preventDefault()
          addComment()
        }}
      >
        <input
          bind:value={comment}
          placeholder="Add a follow-up…"
          class="min-w-0 rounded-xl border-rule bg-well px-3.5 py-2.5 text-sm focus:border-accent focus:bg-white focus:ring-0"
        />
        <button
          class="cursor-pointer rounded-xl bg-accent px-4 text-[13px] font-semibold text-white"
        >
          Post
        </button>
      </form>
    {:else}
      <Link
        href={loginHref()}
        class="mt-4 block w-full rounded-xl border border-rule bg-canvas p-3 text-center text-[13.5px] font-semibold text-body hover:border-accent hover:text-accent"
      >
        Sign in to comment or link
      </Link>
    {/if}
  </div>
</aside>
