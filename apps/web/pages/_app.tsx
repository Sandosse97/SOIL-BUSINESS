import '../styles/globals.css'
import type { AppProps } from 'next/app'
import { useEffect } from 'react'

function AuthGuard({ Component, pageProps }: AppProps) {
  useEffect(() => {
    // simple client-side guard - replace with proper auth later
    const token = localStorage.getItem('jwt')
    if (!token) {
      // allow public pages, otherwise redirect to /login (not implemented)
    }
  }, [])

  return <Component {...pageProps} />
}

export default AuthGuard