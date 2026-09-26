// Copies text and remembers which button did it for a moment, to show "Copied"
export function createCopier() {
  let copied = $state<string | null>(null)
  let timer: ReturnType<typeof setTimeout> | undefined

  return {
    get copied() {
      return copied
    },
    copy(key: string, text: string) {
      navigator.clipboard?.writeText(text).catch(() => {})
      copied = key
      clearTimeout(timer)
      timer = setTimeout(() => (copied = null), 1400)
    },
  }
}
