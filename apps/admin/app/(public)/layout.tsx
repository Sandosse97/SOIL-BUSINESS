export default function PublicLayout({ children }: { children: React.ReactNode }) {
  return <section style={{ padding: 24, maxWidth: 960, margin: '0 auto' }}>{children}</section>;
}
