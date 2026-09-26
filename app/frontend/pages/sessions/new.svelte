<script lang="ts">
  import { untrack } from 'svelte'
  import { Link, useForm } from '@inertiajs/svelte'
  import { roleTone, toneBadge } from '@/lib/tones'
  import type { Member } from '@/types/headquarter'

  let {
    demo_accounts: demoAccounts,
    return_to: returnTo,
  }: { demo_accounts: Pick<Member, 'name' | 'email' | 'role'>[]; return_to: string | null } =
    $props()

  const form = useForm({ email: '', password: '', return_to: untrack(() => returnTo) })

  function signIn(email?: string) {
    if (email) form.email = email
    form.post('/login')
  }

  const input =
    'rounded-xl border-rule bg-well px-3.5 py-3 text-[15px] font-normal text-ink focus:border-accent focus:bg-white focus:ring-0'
</script>

<svelte:head>
  <title>Sign in · Headquarter</title>
</svelte:head>

<div
  class="grid min-h-screen place-items-center bg-[radial-gradient(900px_500px_at_50%_-10%,#e9e8ff_0%,rgba(233,232,255,0)_70%)] px-4 py-8"
>
  <div class="flex w-full max-w-[420px] animate-fade-in flex-col gap-6">
    <div class="flex flex-col items-center gap-3.5 text-center">
      <div
        class="grid size-12 place-items-center rounded-[14px] bg-accent text-[22px] font-extrabold text-white shadow-[0_8px_24px_rgba(79,70,229,.3)]"
      >
        H
      </div>
      <div>
        <h1 class="text-[26px] font-bold tracking-[-0.02em]">Sign in to Headquarter</h1>
        <p class="mt-2 text-sm leading-[1.55] text-pretty text-muted">
          Everything is readable without an account. Sign in to submit ideas, comment, or manage
          sources.
        </p>
      </div>
    </div>

    <form
      class="flex flex-col gap-3.5 rounded-[20px] border border-rule bg-white p-6 shadow-[0_1px_2px_rgba(23,23,26,.04),0_12px_32px_rgba(23,23,26,.05)]"
      onsubmit={(event) => {
        event.preventDefault()
        signIn()
      }}
    >
      <label class="flex flex-col gap-1.5 text-[13px] font-semibold text-body">
        Email
        <input
          type="email"
          bind:value={form.email}
          autocomplete="email"
          placeholder="you@halden.ai"
          class={input}
        />
      </label>
      <label class="flex flex-col gap-1.5 text-[13px] font-semibold text-body">
        Password
        <input
          type="password"
          bind:value={form.password}
          autocomplete="current-password"
          placeholder="••••••••"
          class={input}
        />
      </label>
      <button
        disabled={form.processing}
        class="mt-1 cursor-pointer rounded-xl bg-accent p-3 text-[15px] font-semibold text-white hover:bg-accent-hover disabled:opacity-60"
      >
        Sign in
      </button>
      {#if form.errors.email}
        <div class="text-center text-[13px] text-down">{form.errors.email}</div>
      {/if}

      <div class="mt-1 flex items-center gap-3 text-xs text-faint">
        <span class="h-px flex-1 bg-rule"></span>demo accounts<span class="h-px flex-1 bg-rule"
        ></span>
      </div>
      <div class="flex flex-col gap-1.5">
        {#each demoAccounts as account (account.email)}
          <button
            type="button"
            onclick={() => signIn(account.email)}
            class="flex cursor-pointer items-center justify-between gap-2.5 rounded-xl border border-rule bg-well px-3.5 py-2.5 text-left hover:border-accent hover:bg-white"
          >
            <span>
              <span class="text-sm font-semibold text-ink">{account.name}</span>
              <span class="block text-xs text-muted">{account.email}</span>
            </span>
            <span
              class={[
                'rounded-full px-2.5 py-0.5 text-[11px] font-semibold capitalize',
                toneBadge[roleTone[account.role]],
              ]}
            >
              {account.role}
            </span>
          </button>
        {/each}
      </div>
    </form>

    <Link href={returnTo ?? '/'} class="p-2 text-center text-sm text-muted hover:text-ink">
      ← Continue without signing in
    </Link>
  </div>
</div>
