<script lang="ts">
  import { Link, page } from '@inertiajs/svelte'
  import { loginHref } from '@/lib/session'

  const user = $derived(page.props.current_user)
</script>

<svelte:head>
  <title>Admin · Headquarter</title>
</svelte:head>

<div
  class="mx-auto my-10 flex max-w-[480px] flex-col items-center gap-3 rounded-[20px] border border-rule bg-white p-8 text-center"
>
  <div
    class="grid size-11 place-items-center rounded-[14px] bg-accent-soft text-lg font-extrabold text-accent"
  >
    A
  </div>
  <h2 class="text-xl font-bold tracking-[-0.01em]">Admin is for the technical team</h2>
  <p class="text-sm leading-[1.55] text-pretty text-muted">
    {#if user}
      You are signed in as {user.first_name} ({user.role}). Ask an admin to upgrade your role to
      manage sources and access.
    {:else}
      Sign in with an admin account to connect APIs and MCP servers, add entries by hand, and manage
      who sees what.
    {/if}
  </p>
  {#if !user}
    <Link
      href={loginHref()}
      class="mt-1.5 rounded-full bg-ink px-[18px] py-2.5 text-[13.5px] font-semibold text-white"
    >
      Sign in
    </Link>
  {/if}
</div>
