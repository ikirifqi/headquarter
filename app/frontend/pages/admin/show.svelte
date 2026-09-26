<script lang="ts">
  import { page } from '@inertiajs/svelte'
  import PageHeader from '@/components/PageHeader.svelte'
  import Segmented from '@/components/Segmented.svelte'
  import ApiAccess from '@/components/admin/ApiAccess.svelte'
  import Integrations from '@/components/admin/Integrations.svelte'
  import ManualEntries from '@/components/admin/ManualEntries.svelte'
  import Team from '@/components/admin/Team.svelte'
  import Vendors from '@/components/admin/Vendors.svelte'
  import type {
    ApiAccess as ApiAccessProps,
    Bill,
    Integration,
    ManualArea,
    Member,
    Vendor,
  } from '@/types/headquarter'

  let {
    integrations,
    manual_entries: manualEntries,
    bills,
    vendors,
    api,
    team,
  }: {
    integrations: Integration[]
    manual_entries: ManualArea[]
    bills: Bill[]
    vendors: Vendor[]
    api: ApiAccessProps
    team: { members: Member[]; pages: string[] }
  } = $props()

  // Changes made on these tabs are kept for this visit only; nothing is written back yet.
  type Tab = 'integrations' | 'manual' | 'vendors' | 'access' | 'team'
  let tab = $state<Tab>('integrations')

  const tabs: { value: Tab; label: string }[] = [
    { value: 'integrations', label: 'Integrations' },
    { value: 'manual', label: 'Manual entry' },
    { value: 'vendors', label: 'Vendors & logins' },
    { value: 'access', label: 'API & MCP' },
    { value: 'team', label: 'Team & access' },
  ]

  const owner = $derived(page.props.current_user?.first_name ?? '')
</script>

<PageHeader eyebrow="Admin · technical" title="Manage sources">
  {#snippet aside()}
    <Segmented items={tabs} active={tab} onselect={(value) => (tab = value)} />
  {/snippet}
</PageHeader>

{#if tab === 'integrations'}
  <Integrations {integrations} />
{:else if tab === 'manual'}
  <ManualEntries areas={manualEntries} {bills} />
{:else if tab === 'vendors'}
  <Vendors {vendors} {owner} />
{:else if tab === 'access'}
  <ApiAccess {api} {owner} />
{:else}
  <Team members={team.members} pages={team.pages} />
{/if}
