# Next.js Framework Guidelines

## App Router Patterns

### Server Components
```tsx
// app/users/page.tsx
import { getUsers } from '@/lib/api';

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div>
      <h1>Users</h1>
      <UserList users={users} />
    </div>
  );
}

// app/users/[id]/page.tsx
export async function generateStaticParams() {
  const users = await getUsers();
  return users.map((user) => ({
    id: user.id,
  }));
}

export default async function UserPage({ 
  params 
}: { 
  params: { id: string } 
}) {
  const user = await getUser(params.id);
  
  return <UserProfile user={user} />;
}
```

### Client Components
```tsx
// app/components/SearchBar.tsx
'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';

export function SearchBar() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    startTransition(() => {
      router.push(`/search?q=${encodeURIComponent(query)}`);
    });
  };

  return (
    <form onSubmit={handleSearch}>
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
        disabled={isPending}
      />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Searching...' : 'Search'}
      </button>
    </form>
  );
}
```

### Server Actions
```tsx
// app/actions/user.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const UpdateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

export async function updateUser(userId: string, formData: FormData) {
  const validatedFields = UpdateUserSchema.parse({
    name: formData.get('name'),
    email: formData.get('email'),
  });

  try {
    await db.user.update({
      where: { id: userId },
      data: validatedFields,
    });

    revalidatePath(`/users/${userId}`);
    return { success: true };
  } catch (error) {
    return { 
      success: false, 
      error: 'Failed to update user' 
    };
  }
}

// app/components/UserForm.tsx
import { updateUser } from '@/app/actions/user';

export function UserForm({ userId }: { userId: string }) {
  const updateUserWithId = updateUser.bind(null, userId);

  return (
    <form action={updateUserWithId}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Update</button>
    </form>
  );
}
```

### Route Handlers
```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = searchParams.get('query');

  const users = await getUsers({ query });
  
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  
  try {
    const user = await createUser(body);
    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create user' },
      { status: 400 }
    );
  }
}
```

### Middleware
```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { verifyAuth } from '@/lib/auth';

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('token');

  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  try {
    const verified = await verifyAuth(token.value);
    
    if (!verified) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
    
    // Add user info to headers
    const requestHeaders = new Headers(request.headers);
    requestHeaders.set('x-user-id', verified.userId);
    
    return NextResponse.next({
      request: {
        headers: requestHeaders,
      },
    });
  } catch (error) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
};
```

## Data Fetching Patterns

### Static Generation
```tsx
// app/products/page.tsx
export const revalidate = 3600; // Revalidate every hour

export default async function ProductsPage() {
  const products = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 }
  }).then(res => res.json());

  return <ProductGrid products={products} />;
}
```

### Dynamic Rendering
```tsx
// app/dashboard/page.tsx
import { cookies } from 'next/headers';

export const dynamic = 'force-dynamic';

export default async function DashboardPage() {
  const cookieStore = cookies();
  const token = cookieStore.get('token');

  const userData = await fetch('https://api.example.com/user', {
    headers: {
      Authorization: `Bearer ${token?.value}`,
    },
  }).then(res => res.json());

  return <Dashboard data={userData} />;
}
```

### Streaming
```tsx
// app/posts/page.tsx
import { Suspense } from 'react';

async function PostList() {
  const posts = await getPosts(); // This might take time
  return <div>{posts.map(post => <PostCard key={post.id} {...post} />)}</div>;
}

export default function PostsPage() {
  return (
    <div>
      <h1>Posts</h1>
      <Suspense fallback={<PostsSkeleton />}>
        <PostList />
      </Suspense>
    </div>
  );
}
```

## Optimization Techniques

### Image Optimization
```tsx
import Image from 'next/image';

export function ProductImage({ src, alt }: { src: string; alt: string }) {
  return (
    <Image
      src={src}
      alt={alt}
      width={800}
      height={600}
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
      priority={false}
      placeholder="blur"
      blurDataURL="data:image/jpeg;base64,..."
    />
  );
}
```

### Font Optimization
```tsx
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-roboto-mono',
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

## Project Structure
```
app/
├── (auth)/              # Route group for auth
│   ├── login/
│   └── register/
├── (dashboard)/         # Route group for dashboard
│   ├── layout.tsx      # Dashboard layout
│   ├── page.tsx        # Dashboard home
│   └── settings/
├── api/                # API routes
│   ├── auth/
│   └── users/
├── components/         # Shared components
├── lib/               # Utility functions
├── actions/           # Server actions
└── layout.tsx         # Root layout

public/                # Static assets
styles/               # Global styles
types/               # TypeScript types
```

## Performance Best Practices

### Caching Strategy
```tsx
// Fetch with caching
const data = await fetch('https://api.example.com/data', {
  next: { 
    revalidate: 60,
    tags: ['collection']
  }
});

// On-demand revalidation
import { revalidateTag } from 'next/cache';

export async function POST() {
  revalidateTag('collection');
  return NextResponse.json({ revalidated: true });
}
```

### Bundle Optimization
- Use dynamic imports for large components
- Implement route-based code splitting
- Optimize third-party scripts with next/script
- Monitor bundle size with @next/bundle-analyzer

### SEO Optimization
```tsx
// app/products/[id]/page.tsx
export async function generateMetadata({ 
  params 
}: { 
  params: { id: string } 
}) {
  const product = await getProduct(params.id);

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [product.image],
    },
  };
}
```