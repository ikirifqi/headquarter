export type FlashData = {
  notice?: string
  alert?: string
}

export type Role = 'viewer' | 'editor' | 'admin'

export type CurrentUser = {
  name: string
  first_name: string
  email: string
  role: Role
}

export type Organization = {
  name: string
  // ISO date the mock data is pinned to
  today: string
}

// Props shared from InertiaController via inertia_share
export type SharedProps = {
  organization: Organization
  current_user: CurrentUser | null
}
