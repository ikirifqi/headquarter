// Shapes of the props built from config/dummy.yml by app/models/dummy/*.
// Dates arrive as ISO strings (YYYY-MM-DD).

import type { Role } from '@/types'

export type ServiceStatus = 'operational' | 'degraded' | 'outage'

export type Service = {
  name: string
  description: string
  status: ServiceStatus
  uptime: string
  history: { date: string; status: ServiceStatus }[]
}

export type HealthOverview = {
  degraded: number
  open_incidents: number
}

export type Queue = {
  name: string
  status: 'responding' | 'backlogged' | 'idle'
  depth: number
  latency: string
  last_beat: string
}

export type Incident = {
  date: string
  duration: string
  title: string
  state: 'investigating' | 'identified' | 'monitoring' | 'resolved'
  affected: string
  updates: { time: string; label: string; text: string }[]
}

export type BillKind = 'subscription' | 'usage' | 'one_time'

export type Bill = {
  id: number
  date: string
  platform: string
  description: string
  kind: BillKind
  amount: number
  invoice_no?: string
  account?: string
  method?: string
  source: string
  file?: { name: string; meta: string; url?: string }
}

export type BillingSummary = {
  total: number
  recurring: number
  one_time: number
  count: number
}

export type DueSoon = {
  total: number
  next: Pick<Bill, 'id' | 'date' | 'platform' | 'amount'>[]
}

export type ProjectTab = { id: string; name: string }

export type ProjectOverview = {
  id: string
  name: string
  description: string
  current_epic: string
  next_deliverable: string
  next_date: string
}

export type ProjectCard = ProjectOverview & { done_percent: number }

export type MilestoneStatus = 'done' | 'progress' | 'planned' | 'risk'

export type Milestone = {
  name: string
  starts_on: string
  ends_on: string
  status: MilestoneStatus
  progress: number
  // Position on the timeline, as percentages of its width
  offset: number
  span: number
}

export type TaskStatus = 'done' | 'progress' | 'todo' | 'blocked'

export type Task = {
  id: string
  title: string
  owner: string | null
  status: TaskStatus
}

export type Epic = { name: string; tasks: Task[] }

export type ChangeKind = 'added' | 'changed' | 'fixed'

export type Release = {
  version: string
  date: string
  channel: 'stable' | 'beta' | 'hotfix'
  title: string
  summary: string
  changes: Partial<Record<ChangeKind, string[]>>
}

export type LatestRelease = Release & { project_id: string; project_name: string }

export type MeetingListItem = {
  id: number
  date: string
  title: string
  project_name: string
}

export type Meeting = MeetingListItem & {
  duration: string
  attendees: string
  summary: string
  decisions: string[]
  actions: { text: string; owner: string }[]
  transcript: { who: string; at: string; text: string }[]
}

export type IdeaStage = { id: string; name: string }

export type IdeaLink = {
  kind: 'project' | 'discussion' | 'ticket'
  label: string
  href: string
  chip?: string
  external?: boolean
}

export type LinkOption = IdeaLink & { meta: string }

export type IdeaComment = { who: string; when: string; text: string }

export type Idea = {
  id: number
  stage: string
  title: string
  author: string
  age: string
  tags: string[]
  body: string
  links: IdeaLink[]
  comments: IdeaComment[]
}

export type Integration = {
  area: string
  source: string
  endpoint: string
  schedule: string
  connected: boolean
}

export type ManualArea = {
  id: string
  label: string
  hint: string
  placeholder: string
  items: string[]
}

export type Vendor = {
  id: number
  name: string
  use: string
  login: string
  password?: string
  sso?: string
  owner: string
  two_factor: string
  plan: string
  rotated_on?: string
}

export type ApiKey = {
  id: number
  name: string
  prefix: string
  scopes: string[]
  created_on: string
  last_used: string
  created_by: string
}

export type ApiAccess = {
  base_url: string
  mcp_url: string
  mcp_enabled: boolean
  scopes: string[]
  keys: ApiKey[]
  tools: { name: string; description: string }[]
}

export type Member = {
  name: string
  email: string
  role: Role
  demo: boolean
  pages: string[]
}
