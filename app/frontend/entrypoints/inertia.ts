import { createInertiaApp } from '@inertiajs/svelte'
import AppLayout from '@/layouts/AppLayout.svelte'

createInertiaApp({
  pages: '../pages',

  // The sign-in page is full screen; every other page sits inside the top bar layout.
  layout: (name: string) => (name === 'sessions/new' ? undefined : AppLayout),

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    visitOptions: () => {
      return { queryStringArrayFormat: 'brackets' }
    },
  },
})
