<script lang="ts">
  import { untrack } from 'svelte'
  import { capitalize } from '@/lib/format'
  import { roleTone, toneBadge } from '@/lib/tones'
  import type { Role } from '@/types'
  import type { Member } from '@/types/headquarter'

  let { members: initial, pages }: { members: Member[]; pages: string[] } = $props()

  let members = $state(untrack(() => $state.snapshot(initial)))

  const roles: Role[] = ['viewer', 'editor', 'admin']
  const pageLabel = (page: string) => (page === 'discussions' ? 'Discuss.' : capitalize(page))

  function cycleRole(member: Member) {
    member.role = roles[(roles.indexOf(member.role) + 1) % roles.length]
  }

  function togglePage(member: Member, page: string) {
    member.pages = member.pages.includes(page)
      ? member.pages.filter((p) => p !== page)
      : [...member.pages, page]
  }

  const columns = $derived(`minmax(180px,1.4fr) 110px repeat(${pages.length}, minmax(56px,1fr))`)
</script>

<p class="mb-[18px] max-w-[70ch] text-sm leading-[1.55] text-pretty text-muted">
  Anyone can read every page. Editors can also add Ideas and comments. Admins reach this page.
</p>

<div class="overflow-x-auto rounded-[20px] border border-rule bg-white px-[22px] py-1.5">
  <div class="min-w-[640px]">
    <div
      class="grid gap-2 pt-3.5 pb-2.5 text-[11.5px] font-bold tracking-[.04em] text-muted uppercase"
      style:grid-template-columns={columns}
    >
      <div>Member</div>
      <div>Role</div>
      {#each pages as page (page)}
        <div class="text-center">{pageLabel(page)}</div>
      {/each}
    </div>
    {#each members as member (member.email)}
      <div
        class="grid items-center gap-2 border-t border-hairline py-3 text-sm"
        style:grid-template-columns={columns}
      >
        <div>
          <div class="font-semibold">{member.name}</div>
          <div class="text-xs text-muted">{member.email}</div>
        </div>
        <button
          type="button"
          onclick={() => cycleRole(member)}
          class={[
            'cursor-pointer rounded-full px-2.5 py-1 text-center text-xs font-bold capitalize',
            toneBadge[roleTone[member.role]],
          ]}
        >
          {member.role}
        </button>
        {#each pages as page (page)}
          {@const on = member.pages.includes(page)}
          <button
            type="button"
            role="switch"
            aria-checked={on}
            aria-label={`${member.name} · ${pageLabel(page)}`}
            onclick={() => togglePage(member, page)}
            class={[
              'relative h-[22px] w-9 cursor-pointer justify-self-center rounded-full',
              on ? 'bg-up' : 'bg-toggle-off',
            ]}
          >
            <span
              class={[
                'absolute top-[3px] size-4 rounded-full bg-white shadow-[0_1px_2px_rgba(0,0,0,.2)] transition-[left] duration-150',
                on ? 'left-[17px]' : 'left-[3px]',
              ]}
            ></span>
          </button>
        {/each}
      </div>
    {/each}
  </div>
</div>
