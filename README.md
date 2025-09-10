# Movie Quote Generator

**Project Title:** Movie Quote Generator
**Author:** Noeun Soksokunmengfong

## Description

A web app that displays random movie quotes, including the movie name, character, and images. Built with Next.js, TypeScript, Tailwind CSS, Prisma ORM, and Supabase/PostgreSQL for the database.

## Setup Instructions

1. **Install dependencies:**
   ```powershell
   npm install
   ```
2. **Set up environment variables:**
   - Copy `.env.example` to `.env` and fill in your database connection string (Supabase/PostgreSQL).
3. **Generate Prisma client:**
   ```powershell
   npx prisma generate
   ```
4. **Run database migrations:**
   ```powershell
   npx prisma migrate dev
   ```
5. **Start the development server:**
   ```powershell
   npm run dev
   ```

## Architecture Explanation

- **Frontend:** Built with Next.js and Tailwind CSS. Fetches random quotes from the backend API and displays them with images.
- **Backend:** Next.js API routes handle requests for random quotes, using Prisma ORM to query the database.
- **Database:** Supabase/PostgreSQL stores quotes, movies, characters, and image URLs. Prisma ORM manages database access and migrations.
- **Communication:**
  - The frontend calls `/api/quotes/random` to get a random quote.
  - The backend API route queries the database and returns the quote data as JSON.
  - The frontend displays the quote, movie, character, and images using the received data.
