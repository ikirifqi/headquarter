<script lang="ts">
  import type { Snippet } from 'svelte'
  import { Link, page } from '@inertiajs/svelte'
  import { loginHref } from '@/lib/session'

  let { children }: { children: Snippet } = $props()

  const user = $derived(page.props.current_user)

  const nav = $derived(
    [
      { href: '/', label: 'Dashboard' },
      { href: '/health', label: 'Health' },
      { href: '/billing', label: 'Billing' },
      { href: '/roadmap', label: 'Roadmap' },
      { href: '/progress', label: 'Progression' },
      { href: '/releases', label: 'Releases' },
      { href: '/discussions', label: 'Discussions' },
      { href: '/ideas', label: 'Ideas' },
      { href: '/admin', label: 'Admin', adminOnly: true },
    ].filter((item) => !item.adminOnly || user?.role === 'admin'),
  )

  const path = $derived(page.url.split('?')[0])
  const isActive = (href: string) =>
    href === '/' ? path === '/' : path === href || path.startsWith(href + '/')
</script>

<div class="flex min-h-screen flex-col">
  <header class="sticky top-0 z-10 border-b border-rule bg-canvas/85 backdrop-blur-md">
    <div class="mx-auto flex h-16 max-w-[1200px] items-center gap-5 px-[clamp(16px,3vw,32px)]">
      <Link href="/" class="flex shrink-0 items-center gap-2.5">
        <span
          class="grid size-8 place-items-center rounded-[10px] bg-accent text-[15px] font-extrabold text-white"
        >
          H
        </span>
        <span class="text-base font-bold tracking-[-0.01em] text-ink max-sm:hidden"
          >Headquarter</span
        >
      </Link>

      <nav
        class="justify-[safe_center] flex min-w-0 flex-1 [scrollbar-width:none] gap-1 overflow-x-auto whitespace-nowrap"
      >
        {#each nav as item (item.href)}
          <Link
            href={item.href}
            class={[
              'shrink-0 rounded-full px-3.5 py-2 text-[13.5px] font-semibold transition-colors hover:text-ink',
              isActive(item.href) ? 'bg-white text-ink' : 'text-muted',
            ]}
          >
            {item.label}
          </Link>
        {/each}
      </nav>

      <div class="flex shrink-0 items-center gap-2">
        {#if user}
          <div
            class="flex items-center gap-2.5 rounded-full border border-rule bg-white py-1 pr-1 pl-3"
          >
            <span class="text-[13px] font-semibold whitespace-nowrap">
              {user.first_name}<span class="font-medium text-muted capitalize"
                >{` · ${user.role}`}</span
              >
            </span>
            <Link
              href="/logout"
              method="delete"
              as="button"
              class="cursor-pointer rounded-full bg-canvas px-2.5 py-1.5 text-xs font-semibold text-muted hover:text-ink"
            >
              Sign out
            </Link>
          </div>
        {:else}
          <Link
            href={loginHref(page.url)}
            class="rounded-full bg-ink px-4 py-2 text-[13px] font-semibold text-white hover:bg-black"
          >
            Sign in
          </Link>
        {/if}
      </div>
    </div>
  </header>

  <main class="mx-auto w-full max-w-[1200px] flex-1 px-[clamp(16px,3vw,32px)] pt-9 pb-20">
    {@render children()}
  </main>
</div>
