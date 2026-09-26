<script lang="ts">
  import { untrack } from 'svelte'
  import { Link, page } from '@inertiajs/svelte'
  import IdeaPanel from '@/components/IdeaPanel.svelte'
  import PageHeader from '@/components/PageHeader.svelte'
  import StatusDot from '@/components/StatusDot.svelte'
  import { canWrite, loginHref } from '@/lib/session'
  import { stageTone } from '@/lib/tones'
  import type { Idea, IdeaStage, LinkOption } from '@/types/headquarter'

  let {
    stages,
    ideas: initialIdeas,
    link_options: linkOptions,
  }: {
    stages: IdeaStage[]
    ideas: Idea[]
    link_options: Record<'projects' | 'discussions' | 'tickets', LinkOption[]>
  } = $props()

  // Ideas, comments and links added here live only in this page until there is a database.
  let ideas = $state(untrack(() => $state.snapshot(initialIdeas)))
  let openId = $state<number | null>(null)
  let composing = $state(false)
  let draft = $state('')

  const user = $derived(page.props.current_user)
  const writable = $derived(canWrite())
  const openIdea = $derived(ideas.find((idea) => idea.id === openId))
  const firstStage = $derived(stages[0]?.id)
  const columns = $derived(
    stages.map((stage) => ({ ...stage, ideas: ideas.filter((idea) => idea.stage === stage.id) })),
  )

  function submitDraft() {
    const title = draft.trim()
    if (!title || !user || !firstStage) return
    const id = Math.max(0, ...ideas.map((idea) => idea.id)) + 1
    ideas.unshift({
      id,
      stage: firstStage,
      title,
      body: title,
      author: user.first_name,
      age: 'now',
      tags: [],
      links: [],
      comments: [],
    })
    draft = ''
    composing = false
  }

  function updateIdea(updated: Idea) {
    ideas = ideas.map((idea) => (idea.id === updated.id ? updated : idea))
  }
</script>

<PageHeader eyebrow="Ideas" title="What should we build next?">
  {#snippet aside()}
    {#if writable && user}
      <div class="text-[13px] font-medium text-muted">
        {ideas.length} ideas · signed in as {user.first_name}
      </div>
    {:else}
      <Link
        href={loginHref()}
        class="rounded-full border border-rule bg-white px-4 py-2 text-[13px] font-semibold text-body hover:border-accent hover:text-accent"
      >
        Sign in to add or comment
      </Link>
    {/if}
  {/snippet}
</PageHeader>

<div class="flex items-start gap-3.5 overflow-x-auto pb-4">
  {#each columns as column (column.id)}
    <div class="w-[272px] shrink-0 rounded-[18px] bg-column p-2.5">
      <div
        class="flex items-center justify-between px-2 pt-1.5 pb-2.5 text-[12.5px] font-bold text-body"
      >
        <span class="inline-flex items-center gap-2">
          <StatusDot tone={stageTone(column.id)} class="size-2" />
          {column.name}
        </span>
        <span class="text-muted tabular-nums">{column.ideas.length}</span>
      </div>

      <div class="flex flex-col gap-2">
        {#if column.id === firstStage}
          {#if !writable}
            <Link
              href={loginHref()}
              class="rounded-[14px] border-[1.5px] border-dashed border-edge p-3 text-left text-[13px] font-semibold text-faint hover:border-accent hover:text-accent"
            >
              Sign in to add an idea
            </Link>
          {:else if composing}
            <div class="rounded-[14px] border-[1.5px] border-accent bg-white p-3">
              <!-- svelte-ignore a11y_autofocus -->
              <textarea
                bind:value={draft}
                autofocus
                rows="3"
                placeholder="Describe the idea in a sentence…"
                onkeydown={(event) => {
                  if (event.key === 'Enter' && !event.shiftKey) {
                    event.preventDefault()
                    submitDraft()
                  }
                  if (event.key === 'Escape') composing = false
                }}
                class="w-full resize-none border-0 bg-transparent p-0 text-sm leading-normal focus:ring-0"
              ></textarea>
              <div class="mt-2 flex justify-end gap-1.5">
                <button
                  type="button"
                  onclick={() => {
                    composing = false
                    draft = ''
                  }}
                  class="cursor-pointer px-2.5 py-1.5 text-[13px] font-semibold text-muted"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onclick={submitDraft}
                  class="cursor-pointer rounded-full bg-accent px-3.5 py-1.5 text-[13px] font-semibold text-white"
                >
                  Add idea
                </button>
              </div>
            </div>
          {:else}
            <button
              type="button"
              onclick={() => (composing = true)}
              class="cursor-pointer rounded-[14px] border-[1.5px] border-dashed border-edge p-3 text-left text-sm font-semibold text-muted hover:border-accent hover:text-accent"
            >
              + New idea
            </button>
          {/if}
        {/if}

        {#each column.ideas as idea (idea.id)}
          <button
            type="button"
            onclick={() => (openId = idea.id)}
            class="flex w-full cursor-pointer flex-col gap-2.5 rounded-[14px] border border-rule bg-white p-3.5 text-left hover:border-accent-ring hover:shadow-[0_6px_18px_rgba(23,23,26,.06)]"
          >
            <div class="text-[14.5px] leading-[1.4] font-semibold text-pretty text-ink">
              {idea.title}
            </div>
            <div class="flex flex-wrap gap-1.5">
              {#each idea.tags as tag (tag)}
                <span
                  class="rounded-full bg-accent-soft px-2 py-0.5 text-[11px] font-semibold text-accent"
                >
                  {tag}
                </span>
              {/each}
              {#each idea.links.filter((link) => link.chip) as link (link.label)}
                <span
                  class="rounded-full border border-rule bg-canvas px-2 py-0.5 text-[11px] font-semibold text-muted"
                >
                  {link.chip}
                </span>
              {/each}
            </div>
            <div class="flex justify-between text-xs font-medium text-faint">
              <span>{idea.author} · {idea.age}</span>
              <span>{idea.comments.length} comments</span>
            </div>
          </button>
        {/each}
      </div>
    </div>
  {/each}
</div>

{#if openIdea}
  <IdeaPanel
    idea={openIdea}
    stageName={stages.find((stage) => stage.id === openIdea.stage)?.name ?? openIdea.stage}
    {linkOptions}
    onchange={updateIdea}
    onclose={() => (openId = null)}
  />
{/if}
