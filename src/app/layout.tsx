import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Smart Cloches | IoT Servo Controller",
  description: "Advanced IoT dashboard to control smart cloches servo motors via Blynk API.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
