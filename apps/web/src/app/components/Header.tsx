import { Badge } from "@/components/ui/badge";

export default function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-14 max-w-screen-2xl items-center justify-between">
        <div className="flex items-center space-x-4">
          <span className="font-semibold">Kapitel: 1</span>
          <span className="text-muted-foreground">/</span>
          <span className="font-semibold">Beat: 3</span>
        </div>
        <div className="flex items-center space-x-2">
          <Badge variant="outline">Persona: Default</Badge>
          <Badge variant="destructive">Spoiler-Gate: Welt</Badge>
        </div>
      </div>
    </header>
  );
}
