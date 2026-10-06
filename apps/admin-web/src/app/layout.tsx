import type { Metadata } from "next";
import { Inter, Space_Grotesk } from "next/font/google";
import "./globals.css";
import { getLocale } from "@/lib/locale";

const inter = Inter({ variable: "--font-inter", subsets: ["latin", "cyrillic"] });
const spaceGrotesk = Space_Grotesk({ variable: "--font-space-grotesk", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Audit",
};

export default async function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang={await getLocale()} className={`${inter.variable} ${spaceGrotesk.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
