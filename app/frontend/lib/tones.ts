// Maps the status values in config/dummy.yml to colours. Class names are spelled out in full so
// Tailwind can find them.

export type Tone = 'up' | 'warn' | 'risk' | 'down' | 'info' | 'accent' | 'muted'

export const toneText: Record<Tone, string> = {
  up: 'text-up',
  warn: 'text-warn',
  risk: 'text-risk',
  down: 'text-down',
  info: 'text-info',
  accent: 'text-accent',
  muted: 'text-muted',
}

export const toneDot: Record<Tone, string> = {
  up: 'bg-up',
  warn: 'bg-warn',
  risk: 'bg-risk',
  down: 'bg-down',
  info: 'bg-info',
  accent: 'bg-accent',
  muted: 'bg-muted',
}

export const toneBadge: Record<Tone, string> = {
  up: 'bg-up-soft text-up',
  warn: 'bg-warn-soft text-warn',
  risk: 'bg-risk-soft text-risk',
  down: 'bg-down-soft text-down',
  info: 'bg-info-soft text-info',
  accent: 'bg-accent-soft text-accent',
  muted: 'bg-hairline text-muted',
}

export const serviceTone = { operational: 'up', degraded: 'warn', outage: 'down' } as const
export const serviceLabel = { operational: 'Operational', degraded: 'Degraded', outage: 'Outage' }
export const serviceBar = {
  operational: 'bg-green-500',
  degraded: 'bg-amber-500',
  outage: 'bg-red-500',
}

export const queueTone = { responding: 'up', backlogged: 'warn', idle: 'muted' } as const

export const incidentTone = (state: string): Tone => (state === 'resolved' ? 'up' : 'warn')

export const billKindTone = { subscription: 'muted', usage: 'info', one_time: 'warn' } as const
export const billKindLabel = { subscription: 'Subscription', usage: 'Usage', one_time: 'One-time' }

export const channelTone = { stable: 'up', beta: 'info', hotfix: 'down' } as const

export const changeTone = { added: 'up', changed: 'info', fixed: 'accent' } as const

export const milestoneStyle = {
  done: { track: 'bg-up', fill: 'bg-up', text: 'text-white', label: 'Delivered' },
  progress: { track: 'bg-accent-track', fill: 'bg-accent', text: 'text-ink', label: 'In progress' },
  planned: { track: 'bg-rule', fill: 'bg-rule', text: 'text-muted', label: 'Planned' },
  risk: { track: 'bg-risk-soft', fill: 'bg-risk', text: 'text-ink', label: 'At risk' },
}

export const taskStyle = {
  progress: { ring: 'border-accent', text: 'text-accent', label: 'In progress', order: 0 },
  blocked: { ring: 'border-down', text: 'text-down', label: 'Blocked', order: 1 },
  todo: { ring: 'border-edge', text: 'text-faint', label: 'Up next', order: 2 },
  done: { ring: 'border-up bg-up', text: 'text-up', label: 'Done', order: 3 },
}

const stageTones: Record<string, Tone> = {
  new: 'muted',
  reviewing: 'info',
  accepted: 'accent',
  progress: 'warn',
  shipped: 'up',
}
export const stageTone = (stage: string): Tone => stageTones[stage] ?? 'muted'

export const roleTone = { viewer: 'muted', editor: 'info', admin: 'accent' } as const
