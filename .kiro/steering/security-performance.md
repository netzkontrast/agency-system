---
inclusion: always
---

# Security and Performance Guidelines

## Security Best Practices

### API Security

#### Input Validation and Sanitization
```typescript
import { z } from 'zod';
import DOMPurify from 'isomorphic-dompurify';

// Comprehensive input validation
const SecureInputSchema = z.object({
  content: z.string()
    .min(1, "Content required")
    .max(50000, "Content too large")
    .refine(val => !/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi.test(val), {
      message: "Script tags not allowed"
    }),
  metadata: z.object({
    source: z.string().min(1).max(255),
    chapter: z.string().max(100).optional(),
    beat: z.string().max(100).optional()
  })
});

// Sanitize HTML content
function sanitizeContent(content: string): string {
  return DOMPurify.sanitize(content, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'u'],
    ALLOWED_ATTR: []
  });
}

// Rate limiting implementation
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 h'), // 100 requests per hour
  analytics: true,
});

export async function withRateLimit(request: NextR