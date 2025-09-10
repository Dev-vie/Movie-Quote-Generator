"use client";
import { Button } from "@/components/ui/button";
import { Facebook, Instagram, Twitter } from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { useState, useEffect } from "react";

type Quote = {
  id: number;
  quote: string;
  movie: string;
  character: string;
  poster_url: string | null;
  character_url: string | null;
};
export default function Home() {
  const [quote, setQuote] = useState<Quote | null>(null);

  const fetchQuote = async () => {
    try {
      const res = await fetch("/api/quotes/random");
      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.error || `HTTP error! status: ${res.status}`);
      }
      const data: Quote = await res.json();
      setQuote(data);
    } catch (err: unknown) {
      if (err instanceof Error) {
        setQuote(null);
      } else {
        setQuote(null);
      }
    }
  };

  useEffect(() => {
    fetchQuote();
  }, []);
  return (
    <div
      style={{
        background: "linear-gradient( #0F172A, #1E293B, #111827)",
        minHeight: "100vh",
        fontFamily: "Indie Flower, sans-serif",
      }}
    >
      <section
        style={{
          display: "flex",
          justifyContent: "center",
          paddingTop: 80,
          color: "#F9FAFB",
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            flexDirection: "column",
            gap: "65px",
          }}
        >
          <h1 style={{ fontSize: "50px" }}>Movie Quote Generator</h1>
          <div
            style={{
              display: "flex",
              flexDirection: "row",
              gap: "10px",
              alignContent: "center",
              justifyContent: "center",
            }}
          >
            {/* Movie Poster */}
            <div
              style={{
                border: "1px solid white",
                borderRadius: "10px",
                maxWidth: "500px",
                maxHeight: "500px",
              }}
            >
              {quote?.poster_url ? (
                <Image
                  src={quote.poster_url}
                  alt={quote.movie}
                  width={500}
                  height={500}
                  style={{
                    width: "100%",
                    height: "100%",
                    borderRadius: "10px",
                    objectFit: "cover",
                    objectPosition: "center",
                  }}
                />
              ) : (
                <p>Poster</p>
              )}
            </div>
            {/* Content */}
            <div
              style={{
                minWidth: "800px",
                minHeight: "400px",
                padding: "10px 20px",
                borderRadius: "10px",
                backgroundColor: "#1F2937",
                boxShadow: "0 4px 6px rgba(0, 0, 0, 0.1)",
                border: "2px solid white",
              }}
            >
              <p
                style={{
                  fontSize: "36px",
                  minHeight: "300px",
                  maxWidth: "800px",
                  display: "flex",
                  justifyContent: "center",
                  alignItems: "center",
                  textAlign: "center",
                  wordBreak: "break-word",
                  overflowWrap: "break-word",
                  whiteSpace: "pre-line",
                }}
              >
                {quote ? `"${quote.quote}"` : "Click Next Quote to start!"}
              </p>
              <p
                style={{
                  fontSize: "36px",
                  minHeight: "100px",
                  maxWidth: "800px",
                  display: "flex",
                  justifyContent: "flex-end",
                  alignItems: "center",
                  textAlign: "right",
                }}
              >
                From
                <span style={{ color: "#00d8feff", fontWeight: "bold" }}>
                  &nbsp;{quote ? `${quote.movie}` : "Movie Name"}
                </span>
              </p>
              <p
                style={{
                  fontSize: "36px",
                  minHeight: "100px",
                  maxWidth: "800px",
                  display: "flex",
                  justifyContent: "flex-end",
                  alignItems: "center",
                  textAlign: "right",
                  marginTop: "-40px",
                }}
              >
                -
                <span style={{ color: "#d8ff28ff", fontWeight: "bold" }}>
                  &nbsp;{quote ? `${quote.character}` : "Character Name"}
                </span>
              </p>
            </div>
            {/* Character Poster */}
            <div
              style={{
                border: "1px solid white",
                borderRadius: "10px",
                maxWidth: "350px",
                maxHeight: "500px",
              }}
            >
              {quote?.character_url ? (
                <Image
                  src={quote.character_url}
                  alt={quote.character}
                  width={350}
                  height={500}
                  style={{
                    width: "100%",
                    height: "100%",
                    borderRadius: "10px",
                    objectFit: "cover",
                    objectPosition: "center",
                  }}
                />
              ) : (
                <p>Character</p>
              )}
            </div>
          </div>
          <Button
            style={{ fontSize: "36px", padding: "10px" }}
            onClick={fetchQuote}
          >
            Next Quote
          </Button>
          <div
            style={{
              display: "flex",
              gap: "25px",
              alignItems: "center",
              color: "#9CA3AF",
              fontSize: "24px",
              justifyContent: "center",
            }}
          >
            <p>Follow Me:</p>
            <Link
              href="https://www.facebook.com/1dledev"
              target="_blank"
              rel="nooperner noreferrer"
            >
              <Button
                variant="ghost"
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  fontSize: "24px",
                }}
              >
                <Facebook style={{ width: "40px", height: "40px" }} />
                Dev Vie
              </Button>
            </Link>
            <Link
              href="https://www.instagram.com/just.devvie"
              target="_blank"
              rel="nooperner noreferrer"
            >
              <Button
                variant="ghost"
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  fontSize: "24px",
                }}
              >
                <Instagram style={{ width: "40px", height: "40px" }} />
                just.devvie
              </Button>
            </Link>
            <Link
              href="https://x.com/dev_vibe"
              target="_blank"
              rel="nooperner noreferrer"
            >
              <Button
                variant="ghost"
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  fontSize: "24px",
                }}
              >
                <Twitter style={{ width: "40px", height: "40px" }} />
                Dev
              </Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
