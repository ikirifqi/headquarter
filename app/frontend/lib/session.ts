import { page } from '@inertiajs/svelte'

// Sign-in link that brings the member back to where they were
export function loginHref(returnTo: string = page.url): string {
  return `/login?return_to=${encodeURIComponent(returnTo)}`
}

// Editors and admins may add ideas, comments and links
export function canWrite(): boolean {
  const role = page.props.current_user?.role
  return role === 'editor' || role === 'admin'
}
