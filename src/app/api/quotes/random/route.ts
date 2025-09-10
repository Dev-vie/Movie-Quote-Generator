import { NextResponse } from "next/server";
import prisma from "@/lib/db";

export async function GET() {
  try {
    const count = await prisma.quote.count();
    if (count === 0) {
      return NextResponse.json({ error: "No quotes found" }, { status: 404 });
    }
    const skip = Math.floor(Math.random() * count);
    const [randomQuote] = await prisma.quote.findMany({ skip, take: 1 });

    if (!randomQuote) {
      return NextResponse.json({ error: "Could not fetch random quote" }, { status: 500 });
    }

    return NextResponse.json(randomQuote);
  } catch (err) {
    console.error("Error fetching random quote:", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}